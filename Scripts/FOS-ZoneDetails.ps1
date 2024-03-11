using namespace System.Net

function FOS_Zone_Details {
        <#
        .SYNOPSIS
        Displays zone information.

        .DESCRIPTION
        Use this command to display zone configuration information. 
        This command includes sorting and search options to customize the output. 
        If a pattern is specified, the command displays only matching zone configuration names in the defined configuration. 
        When used without operands, the command displays all zone configuration information for the Defined and the Effective configuration.        

        .EXAMPLE
        Display all green zones using pattern search, regardless of the case:
        FOS_Zone_Details -UserName admin -SwitchIP 10.10.10.25 -FOS_Operand ic -FOS_ZoneName Green*

        Display validated output for zone members beginning with "zone"
        FOS_Zone_Details -UserName admin -SwitchIP 10.10.10.25 -FOS_Operand validate FOS_ZoneName zone*

        Display validated output for zone members of effective zone configuration, cann be used with or without ZoneName
        FOS_Zone_Details -UserName admin -SwitchIP 10.10.10.25 -FOS_Operand validate FOS_Mode 2

        Displays configuration information for all Peer Zones
        FOS_Zone_Details -UserName admin -SwitchIP 10.10.10.25 -FOS_Operand peerzone

        Displays configuration information for all Peer Zones, with specifies mode
        FOS_Zone_Details -UserName admin -SwitchIP 10.10.10.25 -FOS_Operand validate FOS_Mode 2

        Display the zone members of aliases beginning with "ali1":
        FOS_Zone_Details -UserName admin -SwitchIP 10.10.10.25 -FOS_Operand alias -FOS_AliasName ali1*

        Display all zones
        FOS_Zone_Details -UserName admin -SwitchIP 10.10.10.25
        
        .LINK
        Brocade® Fabric OS® Command Reference Manual, 9.2.x
        https://techdocs.broadcom.com/us/en/fibre-channel-networking/fabric-os/fabric-os-commands/9-2-x/Fabric-OS-Commands.html
        #>
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$UserName,
        [Parameter(Mandatory,ValueFromPipeline)]
        [ipaddress]$SwitchIP,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("ic","validate","peerzone","alias")]
        [string]$FOS_Operand,
        [Parameter(ValueFromPipeline)]
        [string]$FOS_ZoneName,
        [Parameter(ValueFromPipeline)]
        [string]$FOS_AliasName,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("0","1","2")]
        [Int16]$FOS_Mode = 3
    )
    begin{
        Write-Debug -Message "Begin block |$(Get-Date)"
        # create some var
        $FOS_ZoneList = @()
        $FOS_ZoneEntrys= @()
        $FOS_ZoneCollection = @()

        Write-Debug -Message "Zoneliste`n $FOS_ZoneList, `nZoneEntrys`n $FOS_ZoneEntrys, `nZoneCount`n $FOS_ZoneCollection "
        
    }
    process{
        Write-Debug -Message "Start of Process block |$(Get-Date)"
        # Creat a list of Aliase with WWPN based on the decision by AliasName, with a "wildcard" there is only a list similar Aliasen or without a Aliasname there will be all Aliases of the cfg in the List.
        switch ($FOS_Operand) {
            "ic" {

                $FOS_ZoneList = ssh $UserName@$($SwitchIP) "zoneshow --ic ""$FOS_ZoneName"""
                $FOS_ZoneCount = $FOS_ZoneList.count - 1

                0..$FOS_ZoneCount |ForEach-Object {
                    if($FOS_ZoneList[$_] -match '^ zone'){
                        $FOS_ZoneEntrys += $_
                    }
                }
                Write-Debug -Message "FOS_Operand $FOS_Operand`n, SearchZoneName: $FOS_ZoneName`n, Zoneliste`n $FOS_ZoneList, `nZoneEntrys`n $FOS_ZoneEntrys, `nZoneCount`n $FOS_ZoneCount "

            }
            "validate" { 
                if($FOS_Mode -le 2){
                    Write-Host "If this command fails, then it is a known bug under FOS 9.x.x,`n if this is the case then use the command without FOS_Mode parameter" -ForegroundColor Red
                    $FOS_ZoneList = ssh $UserName@$($SwitchIP) "zoneshow --validate ""$FOS_ZoneName"" ,mode $FOS_Mode"
                }else{
                    $FOS_ZoneList = ssh $UserName@$($SwitchIP) "zoneshow --validate ""$FOS_ZoneName"" "
                }
                $FOS_ZoneCount = $FOS_ZoneList.count - 1

                0..$FOS_ZoneCount |ForEach-Object {
                    if($FOS_ZoneList[$_] -match '^ zone'){
                        $FOS_ZoneEntrys += $_
                    }
                }
                
                Write-Debug -Message "FOS_Operand $FOS_Operand`n, SearchZoneName: $FOS_ZoneName`n, FilterMode $FOS_Mode`n, Zoneliste`n $FOS_ZoneList, `nZoneEntrys`n $FOS_ZoneEntrys, `nZoneCount`n $FOS_ZoneCount "
             }
            "peerzone" { 
                if($FOS_Mode -le 2){
                    $FOS_ZoneList = ssh $UserName@$($SwitchIP) "zoneshow --peerzone all -mode $FOS_Mode"
                }else{
                    $FOS_ZoneList = ssh $UserName@$($SwitchIP) "zoneshow --peerzone all "
                }
                $FOS_ZoneCount = $FOS_ZoneList.count - 1

                0..$FOS_ZoneCount |ForEach-Object {
                    if($FOS_ZoneList[$_] -match '^ zone'){
                        $FOS_ZoneEntrys += $_
                    }
                }
                
                Write-Debug -Message "FOS_Operand $FOS_Operand`n, SearchZoneName: $FOS_ZoneName`n, FilterMode $FOS_Mode`n, Zoneliste`n $FOS_ZoneList, `nZoneEntrys`n $FOS_ZoneEntrys, `nZoneCount`n $FOS_ZoneCount "
             }
            "alias" { 
                $FOS_ZoneList = ssh $UserName@$($SwitchIP) "zoneshow --alias ""$FOS_AliasName"""
                $FOS_ZoneCount = $FOS_ZoneList.count - 1

                0..$FOS_ZoneCount |ForEach-Object {
                    if($FOS_ZoneList[$_] -match '^ zone'){
                        $FOS_ZoneEntrys += $_
                    }
                }
                Write-Debug -Message "FOS_Operand $FOS_Operand`n, SearchAliasName: $FOS_AliasName`n, Zoneliste`n $FOS_ZoneList, `nZoneEntrys`n $FOS_ZoneEntrys, `nZoneCount`n $FOS_ZoneCount "
             }
            Default {

                $FOS_ZoneList = ssh $UserName@$($SwitchIP) "zoneshow"
                $FOS_ZoneCount = $FOS_ZoneList.count - 1

                0..$FOS_ZoneCount |ForEach-Object {
                    if($FOS_ZoneList[$_] -match '^ zone'){
                        $FOS_ZoneEntrys += $_
                    }
                }
                Write-Debug -Message "FOS_Operand Default`n, Search: zoneshow`n, Zoneliste`n $FOS_ZoneList, `nZoneEntrys`n $FOS_ZoneEntrys, `nZoneCount`n $FOS_ZoneCount "

            }
        }
        # is not necessary, but even a system needs a break from time to time
        Start-Sleep -Seconds 3;

        # Creat a List of Aliases with WWPN based on switch-case decision
        if(($FOS_ZoneEntrys.count) -ge 1){
            #Create PowerShell Objects out of the Aliases
            foreach ($FOS_ZoneEntry in $FOS_ZoneEntrys) {
                $FOS_TempCollection = "" | Select-Object Zone,Alias
                if (($FOS_ZoneList[$FOS_ZoneEntry].trim() -split "`t").count -gt 2){
                    #Line has Alias and WWN on same line
                    $FOS_TempCollection.Zone = (($FOS_ZoneList[$FOS_ZoneEntry]).trim() -split "`t")[1]
                    $FOS_TempCollection.Alias = (($FOS_ZoneList[$FOS_ZoneEntry]).trim() -split "`t")[2]
                }else{
                    #Line has Alias and WWN on adjascent lines
                    $FOS_TempCollection.Zone = (($FOS_ZoneList[$FOS_ZoneEntry]).trim() -split "`t")[1]
                    $FOS_TempCollection.Alias = $FOS_ZoneList[$FOS_ZoneEntry+1].trim()
                }
                #remove the colons to make it easier to compare to the PowerCLI output
                #$FOS_TempCollection.WWN = ($FOS_TempCollection.WWN).replace(":","")
                $FOS_ZoneCollection += $FOS_TempCollection
            }
            $FOS_ZoneCollection

            Write-Host "Here the list of Aliases with WWPN:`n" -ForegroundColor Green

            Write-Debug -Message "End of Process block |$(Get-Date)"

        }else {
             <# Action when all if and elseif conditions are false #>
            Write-Host "Something wrong, notthing was not found. " -ForegroundColor red
            Write-Debug -Message "Some Infos: notthing was found, ZoneEntry count: $($FOS_ZoneEntrys.count), $FOS_ZoneEntrys"
        }

    }
    end{
        # clear the most of the used vars
        Clear-Variable FOS_* -Scope Local;
        Write-Debug -Message "End block |$(Get-Date)"
    }
}

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

        $FOS_ZoneCollection = @()

        Write-Debug -Message "Zoneliste`n $FOS_ZoneList, `nZoneEntrys`n $FOS_ZoneEntrys, `nZoneCount`n $FOS_ZoneCollection "
        
    }
    process{
        Write-Debug -Message "Start of Process block |$(Get-Date)"
        # Creat a list of Aliase with WWPN based on the decision by AliasName, with a "wildcard" there is only a list similar Aliasen or without a Aliasname there will be all Aliases of the cfg in the List.
        switch ($FOS_Operand) {
            "ic" {

                $FOS_ZoneList = ssh $UserName@$($SwitchIP) "zoneshow --ic ""$FOS_ZoneName"""

                Write-Debug -Message "FOS_Operand $FOS_Operand`n, SearchZoneName: $FOS_ZoneName`n, Zoneliste`n $FOS_ZoneList, `nZoneEntrys`n $FOS_ZoneEntrys, `nZoneCount`n $FOS_ZoneCount "

            }
            "validate" { 
                if($FOS_Mode -le 2){
                    Write-Host "If this command fails, then it is a known bug under FOS 9.x.x,`n if this is the case then use the command without FOS_Mode parameter" -ForegroundColor Red
                    $FOS_ZoneList = ssh $UserName@$($SwitchIP) "zoneshow --validate ""$FOS_ZoneName"" ,mode $FOS_Mode"
                }else{
                    $FOS_ZoneList = ssh $UserName@$($SwitchIP) "zoneshow --validate ""$FOS_ZoneName"" "
                }
                
                Write-Debug -Message "FOS_Operand $FOS_Operand`n, SearchZoneName: $FOS_ZoneName`n, FilterMode $FOS_Mode`n, Zoneliste`n $FOS_ZoneList, `nZoneEntrys`n $FOS_ZoneEntrys, `nZoneCount`n $FOS_ZoneCount "
             }
            "peerzone" { 
                if($FOS_Mode -le 2){
                    $FOS_ZoneList = ssh $UserName@$($SwitchIP) "zoneshow --peerzone all -mode $FOS_Mode"
                }else{
                    $FOS_ZoneList = ssh $UserName@$($SwitchIP) "zoneshow --peerzone all "
                }
                
                Write-Debug -Message "FOS_Operand $FOS_Operand`n, SearchZoneName: $FOS_ZoneName`n, FilterMode $FOS_Mode`n, Zoneliste`n $FOS_ZoneList, `nZoneEntrys`n $FOS_ZoneEntrys, `nZoneCount`n $FOS_ZoneCount "
             }
            "alias" { 

                $FOS_ZoneList = ssh $UserName@$($SwitchIP) "zoneshow --alias ""$FOS_AliasName"""

                Write-Debug -Message "FOS_Operand $FOS_Operand`n, SearchAliasName: $FOS_AliasName`n, Zoneliste`n $FOS_ZoneList, `nZoneEntrys`n $FOS_ZoneEntrys, `nZoneCount`n $FOS_ZoneCount "
             }
            Default {

                #$FOS_BasicZoneList = Get-Content -Path ".\zshow.txt"
                $FOS_BasicZoneList = ssh $UserName@$($SwitchIP) "zoneshow"
                $FOS_ZoneCount = $FOS_BasicZoneList.count

                0..$FOS_ZoneCount |ForEach-Object {
                    # Pull only the effective ZoneCFG back into ZoneList
                    if($FOS_BasicZoneList[$_] -match '^Effective'){
                        $FOS_ZoneList = $FOS_BasicZoneList |Select-Object -Skip $_
                        break
                    }
                }

                Write-Debug -Message "FOS_Operand Default`n, Search: zoneshow`n, Zoneliste`n $FOS_ZoneCount, `nZoneEntrys`n $FOS_BasicZoneList, `nZoneCount`n $FOS_ZoneList "
            }
        }
        # is not necessary, but even a system needs a break from time to time
        Start-Sleep -Seconds 3;

        # Creat a List of Aliases with WWPN based on switch-case decision
        if(($FOS_ZoneList.count) -ge 4){
            #Create PowerShell Objects out of the Aliases
            #$FOS_DoUntilLoop = $true
            foreach ($FOS_Zone in $FOS_ZoneList) {
                $FOS_TempCollection = "" | Select-Object Zone,WWPN,Alias
                # Get the ZoneName
                if(Select-String -InputObject $FOS_Zone -Pattern '^ zone:\s+(.*)'){
                    $FOS_AliName = Select-String -InputObject $FOS_Zone -Pattern '^ zone:\s+(.*)' |ForEach-Object {$_.Matches.Groups[1].Value}
                    $FOS_TempCollection.Zone = $FOS_AliName.Trim()
                    #Write-Host "$FOS_TempCollection" -ForegroundColor Magenta
                }elseif(Select-String -InputObject $FOS_Zone -Pattern '(:[\da-f]{2}:[\da-f]{2}:[\da-f]{2})$') {
                    $FOS_AliWWN = $FOS_Zone
                    $FOS_TempCollection.WWPN = $FOS_AliWWN.Trim()
                    $FOS_DoUntilLoop = $true
                    foreach($FOS_BasicZoneListTemp in $FOS_BasicZoneList){
                        do {
                            if($FOS_BasicZoneListTemp -match '^ alias:\s(.*)'){
                                #Write-Host $FOS_BasicZoneListTemp -ForegroundColor Magenta
                                $FOS_TeampAliasName = $FOS_BasicZoneListTemp
                                $FOS_TempAliasName = $FOS_TeampAliasName -replace '^ alias:\s',''.Trim()
                                break
                                $FOS_SwInfo
                            }
                            if($FOS_BasicZoneListTemp -match ($FOS_AliWWN.Trim())){
                                Write-Host $FOS_BasicZoneListTemp -ForegroundColor Green
                                $FOS_DoUntilLoop = $false
                                $FOS_TempCollection.Alias = $FOS_TempAliasName
                                break
                            }
                            break
                            
                        } until (
                            
                            $FOS_DoUntilLoop -eq $true
                        )
                        If($FOS_DoUntilLoop -eq $false){break}
                    }

                    #Write-Host "$FOS_AliName`n, $FOS_Zone" -ForegroundColor DarkYellow
                }else{
                    <# Action when all if and elseif conditions are false #>
                    Write-Host "`n"
                }
                $FOS_ZoneCollection += $FOS_TempCollection
            }

            Write-Host "Here the list of Zone with Alias:`n" -ForegroundColor Green
            $FOS_ZoneCollection

            Write-Debug -Message "$FOS_ZoneCollection `nEnd of Process block |$(Get-Date)"

        }else {
             <# Action when all if and elseif conditions are false #>
            Write-Host "Something wrong, notthing was not found. " -ForegroundColor red
            Write-Debug -Message "Some Infos: notthing was found, ZoneEntry count: $($FOS_ZoneList.count)`n, $FOS_ZoneList"
        }

    }
    end{
        # clear the most of the used vars
        Clear-Variable FOS_* -Scope Global;
        Write-Debug -Message "End block |$(Get-Date)"
    }
}

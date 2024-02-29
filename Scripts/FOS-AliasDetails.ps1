using namespace System.Net

function FOS_Alias_Details {
        <#
        .DESCRIPTION
        Use the following procedure to add or remove a wwpn to an alias
        Enter the "cfgSave" command to save the change to the defined configuration.

        .EXAMPLE
        To find an Alias by his exact name 
        FOS_Alias_Details -UserName admin -SwitchIP 10.10.10.30 -AliasName Storage_N1_P2

        or by a wildcard
        FOS_Alias_Details -UserName admin -SwitchIP 10.10.10.30 -AliasName Storage*

        To get a list of all aliases with WWPN
        FOS_Alias_Details -UserName admin -SwitchIP 10.10.10.30

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
        [string]$AliasName
    )
    begin{
        Write-Debug -Message "Begin block |$(Get-Date)"
        # create some var
        $AliasList = @()
        $AliasEntrys= @()
        $AliasCollection = @()

        Write-Debug -Message "Aliasliste`n $AliasList, `nAliasEntrys`n $AliasEntrys, `nAliasCount`n $AliasCollection "
        
    }
    process{
        Write-Debug -Message "Start of Process block |$(Get-Date)"
        # Creat a list of Aliase with WWPN based on the decision by AliasName, with a "wildcard" there is only a list similar Aliasen or without a Aliasname there will be all Aliases of the cfg in the List.
        switch ($AliasName) {
            "" {

                $AliasList = ssh $UserName@$($SwitchIP) "alishow"
                $AliasCount = $AliasList.count - 1

                0..$AliasCount |ForEach-Object {
                    if($AliasList[$_] -match '^ alias'){
                        $AliasEntrys += $_
                    }
                }
                Write-Debug -Message "Aliasliste`n $AliasList, `nAliasEntrys`n $AliasEntrys, `nAliasCount`n $AliasCount "

            }
            Default {

                $AliasList = ssh $UserName@$($SwitchIP) "alishow --ic ""$AliasName"""
                $AliasCount = $AliasList.count - 1

                0..$AliasCount |ForEach-Object {
                    if($AliasList[$_] -match '^ alias'){
                        $AliasEntrys += $_
                    }
                }
                Write-Debug -Message "Aliasliste`n $AliasList, `nAliasName`n $AliasName, `nAliasEntrys`n $AliasEntrys, `nAliasCount`n $AliasCount "

            }
        }
        # is not necessary, but even a system needs a break from time to time
        Start-Sleep -Seconds 3;

        # Creat a List of Aliases with WWPN based on switch-case decision
        if(($AliasEntrys.count) -ge 1){
            #Create PowerShell Objects out of the Aliases
            foreach ($AliasEntry in $AliasEntrys) {
                $Alias_TempCollection = "" | Select-Object Alias,WWN
                if (($AliasList[$AliasEntry].trim() -split "`t").count -gt 2){
                    #Line has Alias and WWN on same line
                    $Alias_TempCollection.Alias = (($AliasList[$AliasEntry]).trim() -split "`t")[1]
                    $Alias_TempCollection.WWN = (($AliasList[$AliasEntry]).trim() -split "`t")[2]
                }else{
                    #Line has Alias and WWN on adjascent lines
                    $Alias_TempCollection.Alias = (($AliasList[$AliasEntry]).trim() -split "`t")[1]
                    $Alias_TempCollection.WWN = $AliasList[$AliasEntry+1].trim()
                }
                #remove the colons to make it easier to compare to the PowerCLI output
                $Alias_TempCollection.WWN = ($Alias_TempCollection.WWN).replace(":","")
                $AliasCollection += $Alias_TempCollection
            }
            $AliasCollection

            Write-Host "Here the list of Aliases with WWPN:`n" -ForegroundColor Green

            Write-Debug -Message "End of Process block |$(Get-Date)"

        }else {
             <# Action when all if and elseif conditions are false #>
            Write-Host "Something wrong, $AliasName was not found. " -ForegroundColor red
            Write-Debug -Message "Some Infos: $AliasName, AliasEntry count: $($AliasEntrys.count), $AliasEntrys"
        }

    }
    end{
        # clear the most of the used vars
        Clear-Variable Alias* -Scope Local;
        Clear-Variable *esult -Scope Local;
        Write-Debug -Message "End block |$(Get-Date)"
    }
}

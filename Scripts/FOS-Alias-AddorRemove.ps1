using namespace System.Net

function FOS_Alias_ADDorREM {
        <#
        .DESCRIPTION
        Use the following procedure to add or remove a wwpn to an alias
        Enter the "cfgSave" command to save the change to the defined configuration.

        .EXAMPLE
        To add a WWPN to an alias
        FOS_aliadd -AliasFunc aliadd -UserName admin -SwitchIP 10.10.10.25 -AliasName Array1 -AliasWWPN 21:00:00:20:37:0c:66:23

        To remove a WWPN to an alias
        FOS_aliadd -AliasFunc aliremove -UserName admin -SwitchIP 10.10.10.25 -AliasName Array1 -AliasWWPN 21:00:00:20:37:0c:66:23 

        .LINK
        Brocade® Fabric OS® Command Reference Manual, 9.1.x
        https://techdocs.broadcom.com/us/en/fibre-channel-networking/fabric-os/fabric-os-commands/9-1-x/Fabric-OS-Commands.html
        #>
    param (
        [Parameter(Mandatory)]
        [ValidateSet("aliadd","aliremove")]
        [string]$AliasFunc,
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$UserName,
        [Parameter(Mandatory,ValueFromPipeline)]
        [ipaddress]$SwitchIP,
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$AliasName,
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$AliasWWPN
    )
    begin{
        Write-Debug -Message "Begin block |$(Get-Date)"
        #give them a default name
        [string]$AliasObject="DummyName"
        $result = ssh $UserName@$($SwitchIP) alishow $AliasName
        Write-Debug -Message $result
        $AliasObject = (($result).Trim() -split "`t")[1]
        Write-Debug -Message $AliasObject
    }
    process{
        Write-Debug -Message "Process block |$(Get-Date)"
        switch ($AliasFunc) {
            "aliadd" {         
                if($AliasName -eq $AliasObject){
                    Write-Host "all fine" -ForegroundColor Green
                    $endResult = ssh $UserName@$($SwitchIP) "$AliasFunc ""$AliasName"",""$AliasWWPN""; cfgsave "
                    Write-Debug -Message $endResult
                }else {
                     <# Action when all if and elseif conditions are false #>
                    Write-Host "Something wrong, $AliasName is not epual $AliasObject or $AliasName was not found. " -ForegroundColor red
                    Write-Debug -Message "Some Infos: $AliasName, $AliasObject, $result"
                }
            }
            "aliremove" {
                if($AliasName -eq $AliasObject){
                    Write-Host "all fine" -ForegroundColor Green
                    $endResult = ssh $UserName@$($SwitchIP) "$AliasFunc ""$AliasName"",""$AliasWWPN""; cfgsave "
                    Write-Debug -Message $endResult
                }else {
                     <# Action when all if and elseif conditions are false #>
                    Write-Host "Something wrong, $AliasName is not epual $AliasObject or $AliasName was not found. " -ForegroundColor red
                    Write-Debug -Message "Some Infos: $AliasName, $AliasObject, $result"
                }
            }
            Default {}
        }
    }
    end{
        Clear-Variable Alias* -Scope Local;
        Write-Debug -Message "End block |$(Get-Date)"
    }
}

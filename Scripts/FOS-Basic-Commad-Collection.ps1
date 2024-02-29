
function FOS_NTP_Server {
        <#
        .DESCRIPTION
        Displays or sets the Network Time Protocol (NTP) Server addresses.

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
            [ipaddress]$NTP_Server,
            [Parameter(ValueFromPipeline)]
            [ValidateSet("show","showkeys")]
            [string]$NTP_Show
        )
        
        begin{
            Write-Debug -Message "Begin block $(Get-Date)"
            Write-Debug -Message "NTP-Server $NTP_Server, NTP-Show $NTP_Show | $(Get-Date)"
            if((($NTP_Server) -and $NTP_Show) -ne "" ){
                Write-Host "It is not permitted to use the -NTP_Show parameter in combination with the -NTP_Server parameter!" -ForegroundColor Red
                break
            }else{
                Write-Debug -Message "No error found between server and show"
            }
        }
        process{
            Write-Debug -Message "Process block $(Get-Date)"

            if(($NTP_Server -eq "") -or ($NTP_Show -notlike "show*")){
                $endResult = ssh $UserName@$($SwitchIP) "tsclockserver"
            }
            elseif($NTP_Show -notlike "show*"){
                $endResult = ssh $UserName@$($SwitchIP) "tsclockserver ""$NTP_Server"" "
            }else {
                $endResult = ssh $UserName@$($SwitchIP) "tsclockserver --$NTP_Show "
            }
            Write-Debug -Message "$endResult"
        }
        end{
            Write-Debug -Message "End block $(Get-Date)"
            Clear-Variable NTP_Se* -Scope Local;
            Write-Host "$endResult" -ForegroundColor Green
        }
}
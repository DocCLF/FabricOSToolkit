using namespace System.Net

#Write-Host "Attention the 'function FOS_IPAddrSet' requires administrator rights, without these rights your IP config cannot be customized and the script runs into an error!" -ForegroundColor Red
function FOS_NEW_Director_Chassis_IPAddrSet {
    <#
        .DESCRIPTION
        The device requires three IP addresses, which are configured using the ipAddrSet command. 
        IP addresses are required for both CP blades (CP0 and CP1) and for chassis management (shown as SWITCH under the ipAddrShow command) in the device.

        The addresses 10.0.0.0 through 10.0.0.255 are reserved and used internally by the device. 
        External IPs must not use these addresses.
        .EXAMPLE
        set chassis management
        FOS_NEW_Director_Chassis_IPAddrSet -CH_MgmtIPAddr 10.10.15.10 -CH_MgmtSubNet 10.10.15.1 -SAN_DHCP off

        .LINK
        Brocade® X7-8 Director Hardware Installation Guide
        https://techdocs.broadcom.com/us/en/fibre-channel-networking/directors/x7-8-director/1-0/GUID-ECC0B3FE-FE66-421E-82BE-01E05193D998_3/v25880345.html
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ipaddress]$CH_MgmtIPAddr,
        [Parameter(Mandatory, ValueFromPipeline)]
        [ipaddress]$CH_MgmtSubNet,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("on","off")]
        [string]$SAN_DHCP="off"
    )
    begin{
        <#This block is used to provide optional one-time preprocessing for the function. The PowerShell runtime uses the code in this block once for each instance of the function in the pipeline.#>
        # Dafault settings based on Brocade Doku
        Write-Host "First, a serial connection to the device is established as described in the Brocade director documentation! Otherwise this process will fail." -ForegroundColor Blue
        Write-Debug -Message "Begin block |$(Get-Date)"
    }
    process {
        <#This block is used to provide record-by-record processing for the function. You can use a process block without defining the other blocks. The number of process block executions depends on how you use the function and what input the function receives.#>
        Write-Debug -Message "Process block startet |$(Get-Date)"

        Write-Debug -Message "New IP CH MGMT of the Director will be $CH_MgmtIPAddr, $CH_MgmtSubNet, DHCP: $SAN_DHCP"
        Write-Host "The new chassis management IP of the Director will be $CH_MgmtIPAddr, $CH_MgmtSubNet, DHCP: $SAN_DHCP" -ForegroundColor Blue

        Write-Host "Copy the following line into your terminal window to enter the chassis management address.`n" -ForegroundColor Blue

        Write-Host "ipAddrSet -chassis -ipv4 -add -ethip $CH_MgmtIPAddr -ethmask $CH_MgmtSubNet -dhcp $SAN_DHCP" -ForegroundColor DarkMagenta

        Write-Host "`n"

        Write-Debug -Message "Process block done |$(Get-Date)"
    }
    end{
        <#This block is used to provide optional one-time post-processing for the function.#>
        Clear-Variable CH_* -Scope Local;
        Write-Debug -Message "End block |$(Get-Date)"
    }

}
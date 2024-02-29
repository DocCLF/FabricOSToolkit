using namespace System.Net

function FOS_NEW_Director_CP_IPAddrSet {
    <#
        .DESCRIPTION
        The device requires three IP addresses, which are configured using the ipAddrSet command. 
        IP addresses are required for both CP blades (CP0 and CP1) and for chassis management (shown as SWITCH under the ipAddrShow command) in the device.
        
        CP_Blade = Control Processor Blades
        The default IP addresses and host names for the device are: 
        10.77.77.77 (mgmt)
        10.77.77.75 / CP0 (the CP blade in slot 1 at the time of configuration)
        10.77.77.74 / CP1 (the CP blade in slot 2 at the time of configuration)
        .EXAMPLE
        For CP 0
        FOS_NEW_Director_CP_IPAddrSet -CP_Blade 0 -CP_ProdIPAddr 10.10.15.20 -CP_ProdGW 10.10.15.1 -CP_ProdSubNet 255.255.255.0 -SAN_DHCP off
        For CP 1
        FOS_NEW_Director_CP_IPAddrSet -CP_Blade 1 -CP_ProdIPAddr 10.10.15.21 -CP_ProdGW 10.10.15.1 -CP_ProdSubNet 255.255.255.0 -SAN_DHCP off
        
        .LINK
        Brocade® X7-8 Director Hardware Installation Guide
        https://techdocs.broadcom.com/us/en/fibre-channel-networking/directors/x7-8-director/1-0/GUID-ECC0B3FE-FE66-421E-82BE-01E05193D998_3/v25880345.html
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateSet("0","1")]
        [Int16]$CP_Blade, 
        [Parameter(Mandatory, ValueFromPipeline)]
        [ipaddress]$CP_ProdIPAddr, 
        [Parameter(Mandatory, ValueFromPipeline)]
        [ipaddress]$CP_ProdGW, 
        [Parameter(Mandatory, ValueFromPipeline)]
        [ipaddress]$CP_ProdSubNet,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("on","off")]
        [string]$SAN_DHCP="off"
    )
    begin{
        <#This block is used to provide optional one-time preprocessing for the function. The PowerShell runtime uses the code in this block once for each instance of the function in the pipeline.#>
        # Dafault settings based on Brocade Doku
        <#This block is used to provide optional one-time preprocessing for the function. The PowerShell runtime uses the code in this block once for each instance of the function in the pipeline.#>
        # Dafault settings based on Brocade Doku
        Write-Host "First, a serial connection to the device is established as described in the Brocade director documentation! Otherwise this process will fail." -ForegroundColor Blue
        Write-Debug -Message "Begin block |$(Get-Date)"
    }
    process {
        <#This block is used to provide record-by-record processing for the function. You can use a process block without defining the other blocks. The number of process block executions depends on how you use the function and what input the function receives.#>
        Write-Debug -Message "Process block startet |$(Get-Date)"

        Write-Debug -Message "New IP CP $CP_Blade of the Director will be $CP_ProdIPAddr, $CP_ProdSubNet, $CP_ProdGW DHCP: $SAN_DHCP"
        Write-Host "The new Control Processor Blade $CP_Blade IP of the Director will be $CP_ProdIPAddr, $CP_ProdSubNet, $CP_ProdGW DHCP: $SAN_DHCP" -ForegroundColor Blue

        Write-Host "Copy the following line into your terminal window to enter the CP Blade $CP_Blade IP address.`n" -ForegroundColor Blue

        Write-Host "ipAddrSet -cp $CP_Blade -ipv4 -add -ethip $CP_ProdIPAddr -ethmask $CP_ProdSubNet -gwyip $CP_ProdGW -dhcp $SAN_DHCP" -ForegroundColor DarkMagenta

        Write-Host "`nRepeat the command for the partner CP." -ForegroundColor Blue

        Write-Host "`n"

        Write-Debug -Message "Process block done |$(Get-Date)"
    }
    end{
        <#This block is used to provide optional one-time post-processing for the function.#>
        Clear-Variable CP_* -Scope Local;
        Write-Debug -Message "End block |$(Get-Date)"
    }

}

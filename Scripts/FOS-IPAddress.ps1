using namespace System.Net

Write-Host "Attention the 'function FOS_IPAddrSet' requires administrator rights, without these rights your IP config cannot be customized and the script runs into an error!" -ForegroundColor Red
function FOS_IPAddrSet {
    <#
        .DESCRIPTION
        Many text in here

        .EXAMPLE
        FOS_newIPAddrSet -ip 10120012
        
        .LINK
        goggel if you can
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [ipaddress]$SAN_ProdIPAddr, 
        [Parameter(Mandatory, ValueFromPipeline)]
        [ipaddress]$SAN_ProdGW, 
        [Parameter(Mandatory, ValueFromPipeline)]
        [ipaddress]$SAN_ProdSubNet,
        [Parameter(Mandatory, ValueFromPipeline)]
        [bool]$SAN_DHCP
    )
    
    # Default settings based on Brocade Doku
    [ipaddress]$Temp_UserIPAddr="10.77.77.70"
    [int]$Temp_UserSubMPrefix="16"
    [ipaddress]$Default_FOSIPAddr="10.77.77.77"
    # Saved as a reserve for later function expansion.
    $Current_UserIPAddr

    # Easy setting for DHCP
    if($SAN_DHCP) {$SAN_DHCP_Var="on"}else{$SAN_DHCP_Var="off"}
    # Convert-Subnetmask to CDIR, found this nice lines here https://github.com/BornToBeRoot/PowerShell
    $Octets = $SAN_ProdSubNet.ToString().Split(".") | ForEach-Object -Process {[Convert]::ToString($_, 2)}
    $CIDR_Bits = ($Octets -join "").TrimEnd("0")               
    $CIDR = $CIDR_Bits.Length
    Write-Host "The new IP configuration of the SAN switch will be $SAN_ProdIPAddr, $SAN_ProdGW, $CIDR, DHCP: $SAN_DHCP_Var" -ForegroundColor Blue
    do{
        $User_decision=Read-Host -Prompt "`nPlease enter y for yes or n for quit "
        #$User_decision=Read-Host -Prompt "Please enter a selection"
        switch ($User_decision) {
            "y" { 
                    # Save Useres curent IPAddr maybe for later, the importend thing here is the InterfaceIndex.
                    $Current_UserIPAddr = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet) |Select-Object IPAddress, PrefixLength, InterfaceIndex
                    Write-Debug -Message "User current IP configuration $($Current_UserIPAddr.IPAddress),$($Current_UserIPAddr.PrefixLength),$($Current_UserIPAddr.InterfaceIndex)" -ErrorAction SilentlyContinue
                    #is not necessary, but even a system needs a break from time to time
                    Start-Sleep -Seconds 3
                    Write-Host "Change the current IP configuration, please wait." -ForegroundColor Blue
                    New-NetIPAddress -InterfaceIndex $($Current_UserIPAddr.InterfaceIndex) -IPAddress $Temp_UserIPAddr -PrefixLength $Temp_UserSubMPrefix
                    #is not necessary, but even a system needs a break from time to time
                    Start-Sleep -Seconds 2
                    Write-Host "Done, your Temp IP is $Temp_UserIPAddr" -ForegroundColor Blue

                    Write-Debug -Message "Check if the default Brocade IP $Default_FOSIPAddr is reachable." -ErrorAction SilentlyContinue
                    $job = Test-Connection $Default_FOSIPAddr -Count 1
                    if($($job.status) -eq "Success") {
                        Write-Host "Verification with $($job.status) completed. " -ForegroundColor Green

                        Write-Debug -Message "Connect to switch and set productive address" -ErrorAction SilentlyContinue
                        Write-Host "Set the IP Config in the switch, attention you may get an error message about a connection loss but this is ok." -ForegroundColor Yellow
                        ssh -o "ServerAliveInterval 10" -o "ServerAliveCountMax 35" admin@$Default_FOSIPAddr ipaddrset -ipv4 -add -ethip $SAN_ProdIPAddr -ethmask $SAN_ProdSubNet -gwyip $SAN_ProdGW -dhcp $SAN_DHCP_Var
                        Start-Sleep -Seconds 5;
                        # tbt fill in a new ip adr based on prod ip and check if is online
                        # New-NetIPAddress -InterfaceIndex $($Current_UserIPAddr.InterfaceIndex) -IPAddress $Temp_UserIPAddr -PrefixLength $Temp_UserSubMPrefix
                        Write-Host "Reset the ipv4 settings, you will lose the network connection." -ForegroundColor Blue
                        $results = Set-NetIPInterface -InterfaceIndex $($Current_UserIPAddr.InterfaceIndex) -AddressFamily IPv4 -Dhcp Enabled -AsJob
                        Start-Sleep -Seconds 5;
                        Write-Debug -Message "Reset done, $results" -ErrorAction SilentlyContinue
                        #Wait-Job -Id $results.Id
                        Start-Sleep -Seconds 5;
                        Write-Host $results.state -ForegroundColor Yellow

                        Write-Host "Restart the network adapter, you will lose the network connection." -ForegroundColor Blue
                        $results = Restart-NetAdapter -InterfaceAlias Ethernet -AsJob
                        Start-Sleep -Seconds 5;
                        Write-Debug -Message "Restart done, $results" -ErrorAction SilentlyContinue
                        #Wait-Job -Id $results.Id
                        Start-Sleep -Seconds 5;
                        Write-Host $results.state -ForegroundColor Yellow
                        Start-Sleep -Seconds 3;
                        Write-Host "We are finished, you can continue with the next step.`nYou can reach the switch under $SAN_ProdIPAddr, $SAN_ProdGW, $CIDR" -ForegroundColor Blue
                        break
                    } else {
                        Start-Sleep -Seconds 2;
                        Write-Host "Verification with $($job.status) failed, please check your entries and try again." -ForegroundColor Red
                    }
                }
            "n" {}
            "no" {}
            Default {Write-Host "`nYou have probably made a mistake, try again.`n" -ForegroundColor Red}
        }
    }while ($User_decision -notin @('n','no'))
}

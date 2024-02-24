using namespace System.Net

Write-Host "Attention the 'function FOS_IPAddrSet' requires administrator rights, without these rights your IP config cannot be customized and the script runs into an error!" -ForegroundColor Red
function FOS_Switch_IPAddrSet {
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
        [Parameter(ValueFromPipeline)]
        [ValidateSet("on","off")]
        [string]$SAN_DHCP="off"
    )
    begin{
        <#This block is used to provide optional one-time preprocessing for the function. The PowerShell runtime uses the code in this block once for each instance of the function in the pipeline.#>
        # Dafault settings based on Brocade Doku
        Write-Debug -Message "Begin block |$(Get-Date)"
        [ipaddress]$Temp_UserIPAddr="10.77.77.70"
        [int]$Temp_UserSubMPrefix="16"
        [ipaddress]$Default_FOSIPAddr="10.77.77.77"
        $Current_UserIPAddr
    }
    process {
        <#This block is used to provide record-by-record processing for the function. You can use a process block without defining the other blocks. The number of process block executions depends on how you use the function and what input the function receives.#>
        Write-Debug -Message "Process block startet |$(Get-Date)"
        # Easy setting for DHCP
        # if($SAN_DHCP) {$SAN_DHCP_Var="on"}else{$SAN_DHCP_Var="off"}
        # Convert-Subnetmask to CDIR, found this nice lines here https://github.com/BornToBeRoot/PowerShell
        $Octets = $SAN_ProdSubNet.ToString().Split(".") | ForEach-Object -Process {[Convert]::ToString($_, 2)}
        $CIDR_Bits = ($Octets -join "").TrimEnd("0")               
        $CIDR = $CIDR_Bits.Length
        Write-Debug -Message "New IP Config of the SAN switch will be $SAN_ProdIPAddr, $SAN_ProdGW, $CIDR, DHCP: $SAN_DHCP"
        Write-Host "The new IP configuration of the SAN switch will be $SAN_ProdIPAddr, $SAN_ProdGW, $CIDR, DHCP: $SAN_DHCP" -ForegroundColor Blue
        do{
            $User_decision=Read-Host -Prompt "`nPlease enter y for yes or n for quit "
            #$User_decision=Read-Host -Prompt "Please enter a selection"
            switch ($User_decision) {
                "y" { 
                        # Save Useres current IPAddr maybe for later, the importend thing here is the InterfaceIndex.
                        $Current_UserIPAddr = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias Ethernet) |Select-Object IPAddress, PrefixLength, InterfaceIndex
                        Write-Debug -Message "User current IP configuration $Current_UserIPAddr |$(Get-Date)" -ErrorAction SilentlyContinue
                        #is not necessary, but even a system needs a break from time to time
                        Start-Sleep -Seconds 3
                        <#Use try, catch, and finally blocks to respond to or handle terminating errors in scripts, this is important for the following area #>
                        try {
                            Write-Host "Change the current IP configuration, please wait." -ForegroundColor Blue
                            New-NetIPAddress -InterfaceIndex $($Current_UserIPAddr.InterfaceIndex) -IPAddress $Temp_UserIPAddr -PrefixLength $Temp_UserSubMPrefix
                            #is not necessary, but even a system needs a break from time to time
                            Start-Sleep -Seconds 2
                            Write-Debug -Message "Temp IP-Config $Temp_UserIPAddr, $Temp_UserSubmPrefix |$(Get-Date)" -ErrorAction SilentlyContinue
                            Write-Host "Done, your Temp IP is $Temp_UserIPAddr" -ForegroundColor Blue
                        }
                        catch {
                            <#Do this if a terminating exception happens#>
                            Write-Error $_.Exception.Message
                        }
                        Write-Debug -Message "Check if the default Brocade IP $Default_FOSIPAddr is reachable.|$(Get-Date)"
                        $job = Test-Connection $Default_FOSIPAddr -Count 1 -ErrorAction SilentlyContinue
                        if($($job.status) -eq "Success") {
                            Write-Host "Verification with $($job.status) completed. " -ForegroundColor Green
                            Write-Debug -Message "Test-Connect to switch with $($job.status) and set productive IP-Config to the Switch |$(Get-Date)" -ErrorAction SilentlyContinue
                            Write-Host "Set the IP Config in the switch, attention you may get an error message about a connection loss but this is ok." -ForegroundColor Blue
                            # The ServerAliveInterval will send a keepalive every x seconds (default is 0, which disables this feature if not set to something else)
                            # This will be done ServerAliveCountMax times if no response is received. The default value of ServerAliveCountMax is 3
                            ssh -o "ServerAliveInterval 10" -o "ServerAliveCountMax 5" admin@$Default_FOSIPAddr ipaddrset -ipv4 -add -ethip $SAN_ProdIPAddr -ethmask $SAN_ProdSubNet -gwyip $SAN_ProdGW -dhcp $SAN_DHCP_Var
                            Write-Debug -Message "Set new IP Config and as expected lost connection |$(Get-Date)" -ErrorAction SilentlyContinue
                            Start-Sleep -Seconds 5;
                            # tbt fill in a new ip adr based on prod ip and check if is online
                            # New-NetIPAddress -InterfaceIndex $($Current_UserIPAddr.InterfaceIndex) -IPAddress $Temp_UserIPAddr -PrefixLength $Temp_UserSubMPrefix
                            Write-Host "Reset the ipv4 settings, you will lose the network connection." -ForegroundColor Blue
                            $results = Set-NetIPInterface -InterfaceIndex $($Current_UserIPAddr.InterfaceIndex) -AddressFamily IPv4 -Dhcp Enabled -AsJob
                            Start-Sleep -Seconds 5;
                            Write-Debug -Message "Reset done, $results |$(Get-Date)" -ErrorAction SilentlyContinue
                            #Wait-Job -Id $results.Id
                            Start-Sleep -Seconds 5;
                            Write-Host $results.state -ForegroundColor Blue

                            Write-Host "Restart the network adapter, you will lose the network connection." -ForegroundColor Blue
                            $results = Restart-NetAdapter -InterfaceAlias Ethernet -AsJob
                            Start-Sleep -Seconds 5;
                            Write-Debug -Message "Restart done, $results |$(Get-Date)" -ErrorAction SilentlyContinue
                            #Wait-Job -Id $results.Id
                            Start-Sleep -Seconds 5;
                            Write-Host $results.state -ForegroundColor Blue
                            Start-Sleep -Seconds 3;
                            Write-Host "We are finished, you can continue with the next step.`nYou can reach the switch under $SAN_ProdIPAddr, $SAN_ProdGW, $CIDR" -ForegroundColor Blue
                            Write-Debug -Message "IP Config done $(Get-Date)"
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
        Write-Debug -Message "Process block done |$(Get-Date)"
    }
    end{
        <#This block is used to provide optional one-time post-processing for the function.#>
        Write-Debug -Message "End block |$(Get-Date)"
    }

}

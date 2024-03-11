using namespace System.Net

function FOS_Port_CFG_Details {
    <#
    .DESCRIPTION
    Use this command to display the current configuration of a port. 
    The behavior of this command is platform-specific; output varies depending on port type and platform, and not all options are supported on all platforms.

    .EXAMPLE
    Displays port configuration settings of all Ports:
    FOS_Port_CFG_Details -UserName admin -SwitchIP 10.10.10.25

    Specifies the number of the port to be displayed, relative to its slot for bladed systems. Use FOS_Switch_Show for a listing of valid port numbers.
    FOS_Port_CFG_Details -UserName admin -SwitchIP 10.10.10.25 -FOS_Port 10

    To display the port configuration settings for a range of ports specified by their index numbers:
    FOS_Port_CFG_Details -UserName admin -SwitchIP 10.10.10.25 -FOS_PortRange 0-24

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
        [int]$FOS_Port,
        [Parameter(ValueFromPipeline)]
        [string]$FOS_PortRange

    )
    
    begin{
        Write-Debug -Message "Begin block |$(Get-Date)"
        Write-Debug -Message "$UserName,$SwitchIP,$FOS_Port,$FOS_PortRange"
        if(($FOS_Port -ne "") -and ($FOS_PortInfo -ne "")){Write-Host "FOS_Port in combination with FOS_PortInfo is not allowed" -ForegroundColor red; break}
    }
    process{
        Write-Debug -Message "Process block |$(Get-Date)"
        if($FOS_Port -ne ""){
            $FOS_PortInfo = ssh $UserName@$($SwitchIP) "portcfgshow $FOS_Port"
        }elseif($FOS_PortRange -ne ""){
            $FOS_PortInfo = ssh $UserName@$($SwitchIP) "portcfgshow -i $FOS_PortRange"
        }else{
            $FOS_PortInfo = ssh $UserName@$($SwitchIP) "portcfgshow "
        }
        
    }
    end{
        Write-Debug -Message "End block |$(Get-Date)"
        $FOS_PortInfo
        Write-Debug -Message "Resault: $FOS_PortInfo |$(Get-Date)"
        Clear-Variable FOS* -Scope Local;
    }
}

function FOS_Port_Perf_Show {
    <#
    .DESCRIPTION
    Use this command to display throughput information for all ports on a switch or chassis or to display the information for a specified port or port range.

    .EXAMPLE
    To display performance information for all ports at a one second (default) interval:
    FOS_Port_Perf_Show -UserName admin -SwitchIP 10.10.10.25
    or
    To display port performance for all ports with an interval of 5 seconds:
    OS_Port_Perf_Show -UserName admin -SwitchIP 10.10.10.25 FOS_Port_Time 5

    To display port performance on a chassis for one port:
    FOS_Port_Perf_Show -UserName admin -SwitchIP 10.10.10.25 -FOS_PortRange 0
    or
    To display port performance on a chassis for range of ports:
    FOS_Port_Perf_Show -UserName admin -SwitchIP 10.10.10.25 -FOS_PortRange 0-8

    Displays the transmitter and receiver throughput with an interval of 5 seconds:
    FOS_Port_Perf_Show -UserName admin -SwitchIP 10.10.10.25 -FOS_PortRange 0-24 -FOS_Port_tx y -FOS_Port_rx y FOS_Port_Time 5
    or
    To display transmitter throughput for a single port at a 15 second interval:
    FOS_Port_Perf_Show -UserName admin -SwitchIP 10.10.10.25 -FOS_PortRange 8 -FOS_Port_tx yes FOS_Port_Time 15
    or
    To display receiver throughput for a range of port at a one second (default) interval:
    FOS_Port_Perf_Show -UserName admin -SwitchIP 10.10.10.25 -FOS_PortRange 0-1 -FOS_Port_rx y 

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
        [string]$FOS_PortRange,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("yes","y")]
        [string]$FOS_Port_tx,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("yes","y")]
        [string]$FOS_Port_rx,
        [Parameter(ValueFromPipeline)]
        [int]$FOS_Port_Time

    )
    
    begin{
        Write-Debug -Message "Begin block |$(Get-Date)"
        Write-Debug -Message "$UserName,$SwitchIP,$FOS_PortRange,$FOS_Port_tx,$FOS_Port_rx,$FOS_Port_Time "
        $FOS_TempArray=@($FOS_PortRange,$FOS_Port_tx,$FOS_Port_rx,$FOS_Port_Time)
        $FOS_Flag=@("$FOS_PortRange ", "-tx ", "-rx ", "-t $FOS_Port_Time")
        for ($i = 0; $i -lt $FOS_TempArray.Count; $i++) {
            # Create a list of operands with their values and put them in the correct order
            if([string]::IsNullOrEmpty($FOS_TempArray[$i])){
                Write-Debug -Message "$($FOS_Flag[$i]) $($FOS_TempArray[$i]) are empty"
            }else{
                Write-Debug -Message "$($FOS_Flag[$i]) $($FOS_TempArray[$i])"
                $FOS_List += "$($FOS_Flag[$i])"
            }
        }
    }

    process{
        Write-Debug -Message "Process block |$(Get-Date)"

        $FOS_PortInfo = ssh $UserName@$($SwitchIP) "portperfshow $FOS_List"
        
    }
    end{
        Write-Debug -Message "End block |$(Get-Date)"
        $FOS_PortInfo
        Write-Debug -Message "Resault: $FOS_PortInfo |$(Get-Date)"
        Clear-Variable FOS* -Scope Local;
    }
}

function FOS_Port_Show {
    <#
    .SYNOPSIS
    Displays status and configuration parameters for ports.

    .DESCRIPTION
    Stats means:    Displays port hardware statistics.
    Buffer means:   Displays the buffer usage information for a port group or for all port groups in the switch.
    by Default      Displays status and configuration parameters for ports.
    
    Use FOS_Switch_Show for a listing of valid port numbers.

    .EXAMPLE
    Specifies the number of the port to be displayed, relative to its slot for chassis-based systems.
    FOS_Port_Show -UserName admin -SwitchIP 10.10.10.25 -FOS_Port 6
    .EXAMPLE
    FOS_Port_Show -UserName admin -SwitchIP 10.10.10.25 -FOS_Operand stats -FOS_Port 6
    .EXAMPLE
    FOS_Port_Show -UserName admin -SwitchIP 10.10.10.25 -FOS_Operand buffer -FOS_Port 6

    .LINK
    Brocade® Fabric OS® Command Reference Manual, 9.2.x
    https://techdocs.broadcom.com/us/en/fibre-channel-networking/fabric-os/fabric-os-commands/9-2-x/Fabric-OS-Commands.html
    #>
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$UserName,
        [Parameter(Mandatory,ValueFromPipeline)]
        [ipaddress]$SwitchIP,
        [Parameter(Mandatory,ValueFromPipeline)]
        [Int16]$FOS_Port,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("stats","buffer")]
        [Int16]$FOS_Operand
    )
    
    begin{
        Write-Debug -Message "Begin block |$(Get-Date)"
        Write-Debug -Message "$UserName,$SwitchIP,$FOS_Operand,$FOS_Port"
    }

    process{
        Write-Debug -Message "Process block |$(Get-Date)"

        switch ($FOS_Operand) {
            "stats" { $FOS_PortInfo = ssh $UserName@$($SwitchIP) "portstatsshow $FOS_Port" }
            "buffer" { $FOS_PortInfo = ssh $UserName@$($SwitchIP) "portbuffershow $FOS_Port" }
            Default { $FOS_PortInfo = ssh $UserName@$($SwitchIP) "portshow $FOS_Port" }
        }
        
    }
    end{
        Write-Debug -Message "End block |$(Get-Date)"
        $FOS_PortInfo
        Write-Debug -Message "Resault: $FOS_PortInfo |$(Get-Date)"
        Clear-Variable FOS* -Scope Global;
    }
}

function FOS_EPort_Credits {
    <#
    .SYNOPSIS
    Displays zone information.

    .DESCRIPTION
    Displays status and configuration parameters for ports.

    .EXAMPLE
    Specifies the number of the port to be displayed, relative to its slot for chassis-based systems.
    FOS_EPort_Credits -UserName admin -SwitchIP 10.10.10.25 -FOS_Port 6

    Use FOS_BuffertoBuffer_Calc to calculate credits.

    .LINK
    Brocade® Fabric OS® Command Reference Manual, 9.2.x
    https://techdocs.broadcom.com/us/en/fibre-channel-networking/fabric-os/fabric-os-commands/9-2-x/Fabric-OS-Commands.html
    #>
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$UserName,
        [Parameter(Mandatory,ValueFromPipeline)]
        [ipaddress]$SwitchIP,
        [Parameter(Mandatory,ValueFromPipeline)]
        [ValidateSet("enable","disable","show")]
        [string]$FOS_Operand,
        [Parameter(Mandatory,ValueFromPipeline)]
        [int]$FOS_Port,
        [Parameter(ValueFromPipeline)]
        [int]$FOS_Credits
    )
    
    begin{
        Write-Debug -Message "Begin block |$(Get-Date)"
        Write-Debug -Message "$UserName,$SwitchIP,$FOS_Port"
    }

    process{
        Write-Debug -Message "Process block |$(Get-Date)"

        switch ($FOS_Operand) {
            "disable" { $FOS_PortCredits = ssh $UserName@$($SwitchIP) "portcfgeportcredits --disable $FOS_Port" }
            "show" { $FOS_PortCredits = ssh $UserName@$($SwitchIP) "portcfgeportcredits --show $FOS_Port" }
            Default { $FOS_PortCredits = ssh $UserName@$($SwitchIP) "portcfgeportcredits --enable $FOS_Port $FOS_Credits" }
        }
        
    }
    end{
        Write-Debug -Message "End block |$(Get-Date)"
        $FOS_PortCredits
        Write-Debug -Message "Resault: $FOS_PortCredits |$(Get-Date)"
        Clear-Variable FOS* -Scope Global;
    }
}

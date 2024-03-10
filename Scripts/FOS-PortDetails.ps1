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
using namespace System.Net

function FOS_SFP_Details {
    <#
    .SYNOPSIS
    Displays transceiver module (SFP/SFPDD/QSFP) information.
    
    .DESCRIPTION
    Use this command to display information about Serial Identification SFPs, also known as module definition "4" SFPs. 
    These SFPs provide extended information that describes the SFP capabilities, interfaces, manufacturer, and other information.

    .EXAMPLE
    To display SFPs on a Brocade switch:
    FOS_SFP_Details -UserName admin -SwitchIP 10.10.10.25

    To display SFP information including SFP health parameters:
    FOS_SFP_Details -UserName admin -SwitchIP 10.10.10.25 -FOS_health y

    Specifies the number of the port for which to display the SFP information, relative to its slot for bladed systems. 
    FOS_SFP_Details -UserName admin -SwitchIP 10.10.10.25 -FOS_Port 1

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
        [ValidateSet("yes","y")]
        [string]$FOS_health,
        [Parameter(ValueFromPipeline)]
        [Int16]$FOS_Port

    )
    
    begin{
        Write-Debug -Message "Begin block |$(Get-Date)"
        Write-Debug -Message "$UserName,$SwitchIP,$FOS_health,$FOS_Port"
        if(($FOS_health -ne "") -and ($FOS_Port -ne "")){Write-Host "FOS_health in combination with FOS_Port is not allowed" -ForegroundColor red; break}
    }
    process{
        Write-Debug -Message "Process block |$(Get-Date)"
        if($FOS_health -like "y*"){
            $FOS_SFPInfo = ssh $UserName@$($SwitchIP) "sfpshow -health " 
        }elseif ($FOS_Port -ge 0) {
            $FOS_SFPInfo = ssh $UserName@$($SwitchIP) "sfpshow $FOS_Port " 
        }else{
            $FOS_SFPInfo = ssh $UserName@$($SwitchIP) "sfpshow"
        }
    }
    end{
        Write-Debug -Message "End block |$(Get-Date)"
        $FOS_SFPInfo
        Write-Debug -Message "Resault: $FOS_SFPInfo |$(Get-Date)"
        Clear-Variable FOS* -Scope Global;
    }
}
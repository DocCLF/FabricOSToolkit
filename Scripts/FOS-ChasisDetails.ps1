using namespace System.Net

function FOS_Chasis_Details {
    <#
    .SYNOPSIS
    Displays all field replaceable units (FRUs) or ChasisName or all Infos about the Chasis in the Fabric

    .DESCRIPTION
    Use this command to display the Field Replaceable Unit (FRU) header content for each object in the chassis and chassis backplane version.

    .EXAMPLE
    Displays port configuration settings of all Ports:
    FOS_Chasis_Details -UserName admin -SwitchIP 10.10.10.25

    Displays the chassis name
    FOS_Chasis_Details -UserName admin -SwitchIP 10.10.10.25 -FOS_Operand Name

    Displays information about the chassis including chassis WWN and chassis name.
    FOS_Chasis_Details -UserName admin -SwitchIP 10.10.10.25 -FOS_Operand Fabric

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
        [ValidateSet("Fabric","Name")]
        [string]$FOS_Operand
    )
    
    begin{
        Write-Debug -Message "Begin block |$(Get-Date)"
        Write-Debug -Message "$UserName,$SwitchIP"
    }
    process{
        Write-Debug -Message "Process block |$(Get-Date)"

        switch ($FOS_Operand) {
            "Fabric" { $FOS_ChasisInfo = ssh $UserName@$($SwitchIP) "fabricshow -chassis " }
            "Name" { $FOS_ChasisInfo = ssh $UserName@$($SwitchIP) "chassisname " }
            Default {$FOS_ChasisInfo = ssh $UserName@$($SwitchIP) "chassisshow "}
        }
        
    }
    end{
        Write-Debug -Message "End block |$(Get-Date)"
        $FOS_ChasisInfo
        Write-Debug -Message "Resault: $FOS_ChasisInfo |$(Get-Date)"
        Clear-Variable FOS* -Scope Global;
    }
}
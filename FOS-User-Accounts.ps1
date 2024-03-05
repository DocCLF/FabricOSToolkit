using namespace System.Net

function FOS_User_Mgmt {
        <#
        .DESCRIPTION


        .EXAMPLE

        FOS_User_Mgmt -UserName admin -SwitchIP 10.10.10.25 

        FOS_User_Mgmt -UserName admin -SwitchIP 10.10.10.25 


        .LINK
        Brocade® Fabric OS® Command Reference Manual, 9.1.x
        https://techdocs.broadcom.com/us/en/fibre-channel-networking/fabric-os/fabric-os-commands/9-1-x/Fabric-OS-Commands.html
        #>
    param (
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

    }
    process{
        Write-Debug -Message "Process block |$(Get-Date)"

    }
    end{
        Write-Debug -Message "End block |$(Get-Date)"

    }
}

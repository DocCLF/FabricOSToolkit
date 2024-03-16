using namespace System.Net

function FOS_SAN_Health {
        <#
        .SYNOPSIS
        

        .DESCRIPTION
       

        .EXAMPLE

        
        .LINK
        Brocade® Fabric OS® Command Reference Manual, 9.2.x
        https://techdocs.broadcom.com/us/en/fibre-channel-networking/fabric-os/fabric-os-commands/9-2-x/Fabric-OS-Commands.html
        #>
    param (
    [Parameter(Mandatory,ValueFromPipeline)]
    [string]$UserName,
    [Parameter(Mandatory,ValueFromPipeline)]
    [ipaddress]$SwitchIP
    )
    
    begin {
        Write-Debug -Message "Begin block |$(Get-Date)"

    }
    
    process {
        Write-Debug -Message "Start of Process block |$(Get-Date)"
    }
    
    end {
        Write-Debug -Message "End block |$(Get-Date)"
    }
}
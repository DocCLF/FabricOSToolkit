using namespace System.Net

function FOS_Trunk_Details {
    <#
    .DESCRIPTION
    Use the following procedure to add or remove a wwpn to an alias
    Enter the "cfgSave" command to save the change to the defined configuration.

    .EXAMPLE
    Display trunking information for a switch:
    FOS_Trunk_Details -UserName admin -SwitchIP 10.10.10.25

    Display trunking information along with bandwidth information:
    FOS_Trunk_Details -UserName admin -SwitchIP 10.10.10.25 -FOS_perf y

    Display trunking information along with switch name:
    FOS_Trunk_Details -UserName admin -SwitchIP 10.10.10.25 -FOS_swname y

    Display trunking information, with switch name and bandwidth information:
    FOS_Trunk_Details -UserName admin -SwitchIP 10.10.10.25 -FOS_perf y -FOS_swname y

    Display neighbor details:
    FOS_Trunk_Details -UserName admin -SwitchIP 10.10.10.25 -FOS_slotport y
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
        [string]$FOS_perf,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("yes","y")]
        [string]$FOS_swname,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("yes","y")]
        [string]$FOS_slotport

    )
    
    begin{
        Write-Debug -Message "Begin block |$(Get-Date)"
        Write-Debug -Message "$UserName,$SwitchIP,$FOS_perf,$FOS_swname,$FOS_slotport"
        if(($FOS_slotport -ne "") -and (($FOS_perf -ne "")-or($FOS_swname -ne ""))){Write-Host "FOS_slotport in combination with FOS_perf or FOS_swname is not allowed" -ForegroundColor red; break}
        
        $FOS_TempArray=@($FOS_perf ,$FOS_swname ,$FOS_slotport)
        $FOS_Flag=@("-perf","-swname","-slotport")
        for ($i = 0; $i -lt $FOS_TempArray.Count; $i++) {
            # Create a list of operands with their values and put them in the correct order
            if([string]::IsNullOrEmpty($FOS_TempArray[$i])){
                Write-Debug -Message "$($FOS_TempArray[$i]) $($FOS_Flag[$i]) are empty"
            }else{
                Write-Debug -Message "$($FOS_TempArray[$i]) $($FOS_Flag[$i])"
                $FOS_List += "$($FOS_Flag[$i]) "
            }
        }

    }
    process{
        Write-Debug -Message "Process block |$(Get-Date)"

        $FOS_TrunkInfo = ssh $UserName@$($SwitchIP) "trunkshow $FOS_List " 
        
    }
    end{
        Write-Debug -Message "End block |$(Get-Date)"
        $FOS_TrunkInfo
        Write-Debug -Message "Resault: $FOS_TrunkInfo |$(Get-Date)"
        Clear-Variable FOS* -Scope Global;
    }
}
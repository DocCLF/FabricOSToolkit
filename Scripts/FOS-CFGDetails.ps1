using namespace System.Net

function FOS_CFG_Details {
    <#
    .DESCRIPTION
    Use this command to display the current configuration of a port. 
    The behavior of this command is platform-specific; output varies depending on port type and platform, and not all options are supported on all platforms.

    .EXAMPLE
    Display all zone configurations that start with "Test", regardless of the case:
    FOS_CFG_Details -UserName admin -SwitchIP 10.10.10.25 -FOS_Operand ic -FOS_Pattern Test*

    To display the property members of peer zones:
    FOS_CFG_Details -UserName admin -SwitchIP 10.10.10.25 -FOS_Operand verbose

    To display changes in the current transaction other option is transdiffsonly to display only the changes in the current transaction:
    FOS_CFG_Details -UserName admin -SwitchIP 10.10.10.25 -FOS_Operand transdiffs

    To display only configuration names:
    FOS_CFG_Details -UserName admin -SwitchIP 10.10.10.25 -FOS_Pattern

    To display all zone configuration information:
    FOS_CFG_Details -UserName admin -SwitchIP 10.10.10.25 -FOS_Pattern all 

    To display all zone configurations that start with "Test":
    FOS_CFG_Details -UserName admin -SwitchIP 10.10.10.25 -FOS_Pattern Test*

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
        [ValidateSet("ic","transdiffs","transdiffsonly","verbose")]
        [string]$FOS_Operand,
        [Parameter(ValueFromPipeline)]
        [string]$FOS_Pattern ="*"

    )
    
    begin{
        Write-Debug -Message "Begin block |$(Get-Date)"
        Write-Debug -Message "$UserName,$SwitchIP,$FOS_Operand,$FOS_Pattern"

        if(($FOS_Pattern -ne "")-and (($FOS_Operand -eq "transdiffs") -or ($FOS_Operand -eq "transdiffsonly"))){
            Write-Host "FOS_Pattern in combination with $FOS_Operand is not allowed" -ForegroundColor red; break}
    }
    process{
        Write-Debug -Message "Process block |$(Get-Date)"
        Write-Debug -Message "$UserName,$SwitchIP,$FOS_Operand,$FOS_Pattern"
        switch ($FOS_Operand) {
            "ic" { $FOS_endResult = ssh $UserName@$($SwitchIP) "cfgshow --ic ""$FOS_Pattern""" }
            "transdiffs" { $FOS_endResult = ssh $UserName@$($SwitchIP) "cfgshow --transdiffsonly" }
            "transdiffsonly" { $FOS_endResult = ssh $UserName@$($SwitchIP) "cfgshow --transdiffsonly" }
            "verbose" { $FOS_endResult = ssh $UserName@$($SwitchIP) "cfgshow --verbose" }
            Default {
                if($FOS_Pattern -eq "all"){
                    $FOS_endResult = ssh $UserName@$($SwitchIP) "cfgshow"
                }elseif ($FOS_Pattern -eq "*") {
                    $FOS_endResult = ssh $UserName@$($SwitchIP) "cfgshow ""*"""
                }else {
                    <# Action when all if and elseif conditions are false #>
                    $FOS_endResult = ssh $UserName@$($SwitchIP) "cfgshow ""$FOS_Pattern"""
                }
            }
        }
        
    }
    end{
        Write-Debug -Message "End block |$(Get-Date)"
        $FOS_endResult
        Write-Debug -Message "Resault: $FOS_endResult |$(Get-Date)"
        Clear-Variable FOS* -Scope Global;
    }
}

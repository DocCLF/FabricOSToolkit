using namespace System.Net

function FOS_CFG_Backup {
        <#
        .DESCRIPTION
        This command uploads configuration data to a file. 
        Two types of configuration files can be uploaded with this command: 
        Virtual Fabric configuration parameters and system configuration parameters.

        .EXAMPLE
        To find an Alias by his exact name 
        FOS_CFG_Backup -UserName admin -SwitchIP 10.10.10.30

        or by a wildcard
        FOS_CFG_Backup -UserName admin -SwitchIP 10.10.10.30

        To get a list of all aliases with WWPN
        FOS_CFG_Backup -UserName admin -SwitchIP 10.10.10.30

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
        [ValidateSet("all","chassis","switch","fid","vf")]
        [string]$CFG_Type,
        [Parameter(Mandatory,ValueFromPipeline)]
        [ValidateSet("scp","sftp","ftp","USB")]
        [string]$Protocol,
        [Parameter(ValueFromPipeline)]
        [ValidateRange(1,65535)]
        [int]$Protocol_Port,
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$Ext_Host_IP,
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$Ext_UserName,
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$Ext_Path_FileName,
        [Parameter(ValueFromPipeline)]
        [string]$Ext_Pwd
    )
    begin{
        Write-Debug -Message "Begin block |$(Get-Date)"
        # Collect all variables for an overview
        Write-Debug -Message "UserName: $UserName, SwitchIP: $SwitchIP,`n CFG_Type: $CFG_Type, Protocol: $Protocol, Protocol_Port: $Protocol_Port,`n Ext_Host_IP: $Ext_Host_IP, Ext_UserName: $Ext_UserName, Ext_Path_FileName: $Ext_Path_FileName, Ext_Pwd: $Ext_Pwd "
    }
    process{
        Write-Debug -Message "Start of Process block |$(Get-Date)"
        switch ($Protocol) {
            {$_ -eq ("scp" -or "sftp")} {
                # Not the best solution but one that works, performance and code cleanup come at the very end!
                Write-Debug -Message "Protocol: $Protocol |$(Get-Date)"
                if(($Protocol_Port -and $Ext_Pwd) -ne ""){
                    $endResult = ssh $UserName@$($SwitchIP) "configupload -$CFG_Type -$Protocol -P $Protocol_Port $Ext_Host_IP,$Ext_UserName,$Ext_Path_FileName,$Ext_Pwd"
                }elseif (($Protocol_Port -and $Ext_Pwd) -eq "") {
                    $endResult = ssh $UserName@$($SwitchIP) "configupload -$CFG_Type -$Protocol $Ext_Host_IP,$Ext_UserName,$Ext_Path_FileName"
                }elseif (($Protocol_Port -eq "") -and ($Ext_Pwd -ne "")) {
                    $endResult = ssh $UserName@$($SwitchIP) "configupload -$CFG_Type -$Protocol $Ext_Host_IP,$Ext_UserName,$Ext_Path_FileName,$Ext_Pwd"
                }elseif (($Protocol_Port -ne "") -and ($Ext_Pwd -eq "")) {
                    $endResult = ssh $UserName@$($SwitchIP) "configupload -$CFG_Type -$Protocol -P $Protocol_Port $Ext_Host_IP,$Ext_UserName,$Ext_Path_FileName" 
                }else {
                    <# Action when all if and elseif conditions are false #>
                    Write-Host "Oops, something went wrong" -ForegroundColor Red
                    break
                }
             }
            "ftp" { 
                Write-Debug -Message "Protocol: $Protocol |$(Get-Date)"
             }
            "USB" { 
                Write-Debug -Message "Protocol: $Protocol |$(Get-Date)"
             }
            Default {}
        }
        $endResult
    }
    end{
        # clear the most of the used vars
        Clear-Variable Alias* -Scope Local;
        Clear-Variable *esult -Scope Local;
        Write-Debug -Message "End block |$(Get-Date)"
    }
}

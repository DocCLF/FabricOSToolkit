using namespace System.Net

function FOS_CFG_Backup {
        <#
        .DESCRIPTION
        This command uploads configuration data to a file. 
        Two types of configuration files can be uploaded with this command: 
        Virtual Fabric configuration parameters and system configuration parameters.

        At this time it works only without FID!

        .EXAMPLE
        Uploads the Config with sftp and Port 22 without a password
        FOS_CFG_Backup -UserName admin -SwitchIP 10.10.20.15 -CFG_Type all -Protocol sftp -Protocol_Port 22 -Ext_Host_IP 10.15.15.20 -Ext_UserName root -Ext_Path_FileName .\test.txt

        Uploads the config with scp without a Port but with a password
        FOS_CFG_Backup -UserName admin -SwitchIP 10.10.10.30 -CFG_Type switch -Protocol scp -Ext_Host_IP 10.15.15.20 -Ext_UserName root -Ext_Path_FileName .\test.txt -Ext_Pwd fancypassword

        "FORCE" overwrites an existing file without confirmation. This parameter is valid only with the USB options.
        FOS_CFG_Backup -UserName admin -SwitchIP 10.10.10.30 -CFG_Type force -Protocol USB -Ext_Path_FileName config.txt

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
        [ValidateSet("all","chassis","switch","vf","force")]
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
        if(($CFG_Type -eq "force") -and ($Protocol -ne "USB")){Write-Host "$CFG_Type is only permitted with USB Protocol"; break}
    }
    process{
        Write-Debug -Message "Start of Process block |$(Get-Date)"
        switch ($Protocol) {
            {$_ -like "s*"} {
                # Not the best solution but one that works, performance and code cleanup come at the very end!
                Write-Debug -Message "Protocol: $Protocol Block 1|$(Get-Date)"
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
                # Not the best solution but one that works, performance and code cleanup come at the very end!
                Write-Debug -Message "Protocol: $Protocol  Block 2|$(Get-Date)"
                if($Ext_Pwd -eq ""){
                    $endResult = ssh $UserName@$($SwitchIP) "configupload -$CFG_Type -$Protocol $Ext_Host_IP,$Ext_UserName,$Ext_Path_FileName"
                }else {
                    $endResult = ssh $UserName@$($SwitchIP) "configupload -$CFG_Type -$Protocol $Ext_Host_IP,$Ext_UserName,$Ext_Path_FileName,$Ext_Pwd"
                }
             }
            "USB" { 
                Write-Debug -Message "Protocol: $Protocol  Block 3|$(Get-Date)"
                $endResult = ssh $UserName@$($SwitchIP) "configupload -force -$CFG_Type -$Protocol $Ext_Path_FileName"
             }
            Default {
                Write-Host "Oops, something went wrong damm" -ForegroundColor Red
                break
            }
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

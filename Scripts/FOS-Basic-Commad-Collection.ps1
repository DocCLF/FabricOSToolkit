using namespace System.Net

function FOS_NTP_Server {

    <#
    .DESCRIPTION
    Displays or sets the Network Time Protocol (NTP) Server addresses.

    .EXAMPLE
    To display the default clock server:
    FOS_NTP_Server -UserName admin -SwitchIP 10.10.10.30
    
    To set the NTP server to a specified IP address:
    FOS_NTP_Server -UserName admin -SwitchIP 10.10.10.30 -NTP_Server 10.10.20.30

    To display NTP server authentication state:
    FOS_NTP_Server -UserName admin -SwitchIP 10.10.10.30 -NTP_Show show

    To display NTP Authentication keys:
    FOS_NTP_Server -UserName admin -SwitchIP 10.10.10.30 -NTP_Show showkeys

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
        [ipaddress]$NTP_Server,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("show","showkeys")]
        [string]$NTP_Show
    )
        
    begin{
        Write-Debug -Message "Begin block $(Get-Date)"
        Write-Debug -Message "NTP-Server $NTP_Server, NTP-Show $NTP_Show | $(Get-Date)"
        if((($NTP_Server) -and $NTP_Show) -ne "" ){
            Write-Host "It is not permitted to use the -NTP_Show parameter in combination with the -NTP_Server parameter!" -ForegroundColor Red
            break
        }else{
            Write-Debug -Message "No error found between server and show"
        }
    }
    process{
        Write-Debug -Message "Process block $(Get-Date)"

        if(($NTP_Server -eq "") -or ($NTP_Show -notlike "show*")){
            $FOS_endResult = ssh $UserName@$($SwitchIP) "tsclockserver"
        }
        elseif($NTP_Show -notlike "show*"){
            $FOS_endResult = ssh $UserName@$($SwitchIP) "tsclockserver ""$NTP_Server"" "
        }else {
            $FOS_endResult = ssh $UserName@$($SwitchIP) "tsclockserver --$NTP_Show "
        }
        Write-Debug -Message "$FOS_endResult"
    }
    end{
            Write-Debug -Message "End block $(Get-Date)"
            Clear-Variable NTP_Se* -Scope Local;
            Write-Host "$FOS_endResult" -ForegroundColor Green
            Clear-Variable FOS* -Scope Local;
    }    
}

function FOS_Syslog_Server {
    <#
    .DESCRIPTION
    Configures a syslog server host.

    .EXAMPLE
    To display all syslog IP addresses configured on a switch:
    FOS_Syslog_Server -UserName admin -SwitchIP 10.10.10.30 FOS_Operand show
    
    To configure an IPv4/6 or hostname non-secure syslog server:
    FOS_Syslog_Server -UserName admin -SwitchIP 10.10.10.30 FOS_Operand set -SyslogSrv win2k2-58-113

    To remove the IPv4/6 address or hostname from the list of servers to which error log messages are sent:
    FOS_Syslog_Server -UserName admin -SwitchIP 10.10.10.30 FOS_Operand remove -SyslogSrv 10.20.30.40

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
        [ValidateSet("show","set","remove")]
        [string]$FOS_Operand,
        [Parameter(ValueFromPipeline)]
        [string]$SyslogSrv
    )
    begin{
        Write-Debug -Message "Begin block $(Get-Date)"

        if((($FOS_Operand -eq "set") -or ($FOS_Operand -eq "remove")) -and ($SyslogSrv -eq "")){
            Write-Host "$FOS_Operand needs the SyslogSrv parameter " -ForegroundColor Red
            Write-Debug -Message "$FOS_Operand and $FabricName are set, leave the func | $(Get-Date)"
            break
        }
    }
    process{
        Write-Debug -Message "Process block $(Get-Date)"

        switch ($FOS_Operand) {
            "show" { 
                $FOS_endResult = ssh $UserName@$($SwitchIP) "syslogadmin --$FOS_Operand -ip" 
            }
            "remove" { 
                $FOS_endResult = ssh $UserName@$($SwitchIP) "syslogadmin --$FOS_Operand -ip $SyslogSrv" 
            }
            "set" { 
                $FOS_endResult = ssh $UserName@$($SwitchIP) "syslogadmin --$FOS_Operand -ip $SyslogSrv" 
            }
            Default {Write-Host "Oops, something went wrong" -ForegroundColor Red
            break
            }
        }

        Write-Debug -Message "$FOS_endResult"
    }
    end{
            Write-Debug -Message "End block $(Get-Date)"
            Write-Host "$FOS_endResult" -ForegroundColor Green
            Clear-Variable FOS* -Scope Local;
    }    
    
}

function FOS_Set_Sw_Ch_Names {
    <#
    .DESCRIPTION
    Displays or sets the Network Time Protocol (NTP) Server addresses.

    .EXAMPLE
    Displays the switch & chassis name.
    FOS_Set_Sw_Ch_Names -UserName admin -SwitchIP 10.10.10.30
    
    Sets the switch and chassis name.
    FOS_Set_Sw_Ch_Names -UserName admin -SwitchIP 10.10.10.30 -switchname DMZ_Switch01 -chassisname Prod_Chassis_11

    To set the switch name.
    FOS_Set_Sw_Ch_Names -UserName admin -SwitchIP 10.10.10.30 -switchname LabSwitch01

    To set the chassis name.
    FOS_Set_Sw_Ch_Names -UserName admin -SwitchIP 10.10.10.30 -chassisname TestChassis_11

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
        [string]$SwitchName,
        [Parameter(ValueFromPipeline)]
        [string]$ChassisName
    )
    begin{
        Write-Debug -Message "Begin block $(Get-Date)"
    }
    process{
        Write-Debug -Message "Process block $(Get-Date)"

        $FOS_endResult = ssh $UserName@$($SwitchIP) "switchname $SwitchName && chassisname $ChassisName "

        Write-Debug -Message "$FOS_endResult"
    }
    end{
            Write-Debug -Message "End block $(Get-Date)"
            Write-Host "$FOS_endResult" -ForegroundColor Green
            Clear-Variable FOS* -Scope Local;
    }    
    
}

function FOS_Fabric_Names {
    <#
    .DESCRIPTION
    Configures fabric name and displays the fabric name parameter.

    .EXAMPLE
    To display the fabric name:
    FOS_Fabric_Names -UserName admin -SwitchIP 10.10.10.30 FOS_Operand show
    
    To set fabric name:
    FOS_Fabric_Names -UserName admin -SwitchIP 10.10.10.30 FOS_Operand set -FabricName newfabric

    To clear the fabric name already set:
    FOS_Fabric_Names -UserName admin -SwitchIP 10.10.10.30 FOS_Operand clear

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
        [ValidateSet("show","set","clear")]
        [string]$FOS_Operand,
        [Parameter(ValueFromPipeline)]
        [string]$FabricName
    )
    begin{
        Write-Debug -Message "Begin block $(Get-Date)"

        if((($FOS_Operand -eq "show") -or ($FOS_Operand -eq "clear")) -and ($FabricName -ne "")){
            Write-Host "$FOS_Operand does not work in combination with $FabricName " -ForegroundColor Red
            Write-Debug -Message "$FOS_Operand and $FabricName are set, leave the func | $(Get-Date)"
            break
        }
    }
    process{
        Write-Debug -Message "Process block $(Get-Date)"

        switch ($FOS_Operand) {
            "show" { 
                $FOS_endResult = ssh $UserName@$($SwitchIP) "fabricname --$FOS_Operand " 
            }
            "clear" { 
                $FOS_endResult = ssh $UserName@$($SwitchIP) "fabricname --$FOS_Operand " 
            }
            "set" { 
                $FOS_endResult = ssh $UserName@$($SwitchIP) "fabricname --$FOS_Operand $FabricName" 
            }
            Default {Write-Host "Oops, something went wrong" -ForegroundColor Red
            break
            }
        }

        Write-Debug -Message "$FOS_endResult"
    }
    end{
            Write-Debug -Message "End block $(Get-Date)"
            Write-Host "$FOS_endResult" -ForegroundColor Green
            Clear-Variable FOS* -Scope Local;
    }    
    
}

function FOS_Roles_Show {
        <#
    .DESCRIPTION
    Displays information about the specified roles. For each role, the command displays the role name,
    description, assigned classes and RBAC permissions for each class.

    .EXAMPLE
    To display the fabric name:
    FOS_Roles_Show -UserName admin -SwitchIP 10.10.10.30

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
    begin{
        Write-Debug -Message "Begin block $(Get-Date)"
    }
    process{
        Write-Debug -Message "Process block $(Get-Date)"
        $FOS_endResult = ssh $UserName@$($SwitchIP) "roleconfig --show -all -default" 

        $FOS_endResult
        Write-Debug -Message "Roleconfig: $FOS_endResult"
    }
    end{
        Write-Debug -Message "End block $(Get-Date)"
        Clear-Variable FOS* -Scope Local;
    }
    
}

function FOS_Roles_Permissions {
    <#
    .DESCRIPTION
    Displays information about the specified roles. For each role, the command displays the role name,
    description, assigned classes and RBAC permissions for each class.

    .EXAMPLE
    Displays permissions for all classes.
    FOS_Roles_Permissions -UserName admin -SwitchIP 10.10.10.30 -FOS_Operand all

    Display an alphabetical listing of all MOF classes supported in Fabric OS:
    FOS_Roles_Permissions -UserName admin -SwitchIP 10.10.10.30 -FOS_Operand classlist

    Display the RBAC permissions for the commands included in the UserManagement class
    FOS_Roles_Permissions -UserName admin -SwitchIP 10.10.10.30 FOS_ClassName UserManagement

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
        [ValidateSet("all","classlist")]
        [string]$FOS_Operand,
        [Parameter(ValueFromPipeline)]
        [string]$FOS_ClassName
    )
    begin{
        Write-Debug -Message "Begin block $(Get-Date)"
        Write-Debug -Message "$UserName,$SwitchIP,$FOS_Operand,$FOS_ClassName"
    }
    process{
        Write-Debug -Message "Process block $(Get-Date)"
        switch ($FOS_Operand) {
            "all" { 
                if($FOS_ClassName -ne ""){Write-Host "It is not allowed to use $FOS_Operand with $FOS_ClassName!" -ForegroundColor Red ; break }
                $FOS_endResult = ssh $UserName@$($SwitchIP) "classconfig --show -$FOS_Operand"  
            }
            "classlist" { 
                if($FOS_ClassName -ne ""){Write-Host "It is not allowed to use $FOS_Operand with $FOS_ClassName!" -ForegroundColor Red ; break }
                $FOS_endResult = ssh $UserName@$($SwitchIP) "classconfig --show -$FOS_Operand"
            }
            Default {$FOS_endResult = ssh $UserName@$($SwitchIP) "classconfig --show $FOS_ClassName" }
        }

        $FOS_endResult
        Write-Debug -Message "Roleconfig: $FOS_endResult"
    }
    end{
        Write-Debug -Message "End block $(Get-Date)"
        Clear-Variable FOS* -Scope Local;
    }

}

function FOS_BuffertoBuffer_Calc {
    <#
    .SYNOPSIS
    Calculates the number of buffers required per port.

    .DESCRIPTION
    Displays information about the specified roles. For each role, the command displays the role name,
    description, assigned classes and RBAC permissions for each class.

    .EXAMPLE
    To display the fabric name:
    FOS_BuffertoBuffer_Calc -FOS_Distance 10 -FOS_Speed 16 -FOS_Framesize 1024

    .LINK
    Brocade® Fabric OS® Command Reference Manual, 9.2.x
    https://techdocs.broadcom.com/us/en/fibre-channel-networking/fabric-os/fabric-os-commands/9-2-x/Fabric-OS-Commands.html
    #>
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [Int32]$FOS_Distance,
        [Parameter(Mandatory,ValueFromPipeline)]
        [ValidateSet(1,2,4,8,10,16,32,64)]
        [Int32]$FOS_Speed,
        [Parameter(Mandatory,ValueFromPipeline)]
        [ValidateSet(512,1024,2048)]
        [Int32]$FOS_Framesize,
        [Parameter()]
        [ParameterType]$FOS_FrameMutliplikator
    )
    begin{
        Write-Debug -Message "Begin block $(Get-Date)"
        Write-Debug -Message "UserName: $UserName, SwitchIP: $SwitchIP, FOS_Port: $FOS_Port, FOS_Distance: $FOS_Distance, FOS_Speed: $FOS_Speed, FOS_Framesize: $FOS_Framesize"
        # Buffer to Buffer Calc
        switch ($FOS_Framesize) {
            512 { [int]$FOS_FrameMutliplikator = 96}
            1024 { [int]$FOS_FrameMutliplikator = 32 }
            2048 { [int]$FOS_FrameMutliplikator = 0 }
            Default {[int]$FOS_FrameMutliplikator = 32}
        }
        $FOS_FrameMutliplikator
        $FOS_BufferResult = (($FOS_Distance*$FOS_Speed/2)+$FOS_FrameMutliplikator)+6
        Write-Debug -Message "Roleconfig: $FOS_BufferResult"
        Write-Host "$FOS_BufferResult buffers required for $($FOS_Distance)km at $($FOS_Speed)G and framesize of $($FOS_Framesize)bytes" -ForegroundColor Green
        Write-Host "`nDo you want to add this Credits to change the default credit allocation for a normal E_Port or EX_port?" -ForegroundColor Green
        Write-Host "yes or y"
        Write-Host "no or n (Default)`n"
        $FOS_SendResult = Read-Host "Do you want to send the result to SAN-Switch [no]"

        Write-Debug -Message "Begin block $(Get-Date) $FOS_SendResult"
        
    }
    process{

        Write-Debug -Message "Process block $(Get-Date) $FOS_SendResult"
        if($FOS_SendResult -like "y*"){
            [string]$UserName = Read-Host "Admin Username "
            [ipaddress]$SwitchIP = Read-Host "Switch IP "
            [int]$FOS_Port = Read-Host "Port "
            Write-Debug -Message "UserName: $UserName, SwitchIP: $SwitchIP, FOS_Port: $FOS_Port, FOS_Distance: $FOS_Distance, FOS_Speed: $FOS_Speed, FOS_Framesize: $FOS_Framesize, FOS_BufferResult: $FOS_BufferResult"

            $FOS_endResult = ssh $UserName@$($SwitchIP) "portcfgeportcredits --enable $FOS_Port $FOS_BufferResult"

        }else{

            break
        }

        $FOS_endResult
        Write-Debug -Message "Roleconfig: $FOS_endResult"
    }
    end{
        Write-Debug -Message "End block $(Get-Date)"
        Clear-Variable FOS* -Scope Global;
    }

}

function FOS_CLI_History {
    <#
    .SYNOPSIS
    Displays switch command history.
    
    .DESCRIPTION
    Displays information about the specified roles. For each role, the command displays the role name,
    description, assigned classes and RBAC permissions for each class.

    .EXAMPLE
    To display the command history on a switch:
    FOS_Roles_Show -UserName admin -SwitchIP 10.10.10.30

    Displays the CLI history of the current user.
    FOS_Roles_Show -UserName admin -SwitchIP 10.10.10.30 -FOS_Operand show

    Displays the CLI history of the given user.
    FOS_Roles_Show -UserName admin -SwitchIP 10.10.10.30 -FOS_Operand showuser -FOS_UserName Testuser

    Displays the CLI history of all users.
    FOS_Roles_Show -UserName admin -SwitchIP 10.10.10.30 -FOS_Operand showall

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
        [ValidateSet("show","showuser","showall")]
        [string]$FOS_Operand,
        [Parameter(ValueFromPipeline)]
        [string]$FOS_UserName
    )
    begin{
        Write-Debug -Message "Begin block $(Get-Date)"
    }
    process{
        Write-Debug -Message "Process block $(Get-Date)"
        switch ($FOS_Operand) {
            "show" { $FOS_endResult = ssh $UserName@$($SwitchIP) "clihistory --show"  }
            "showuser" { $FOS_endResult = ssh $UserName@$($SwitchIP) "clihistory --showuser $FOS_UserName"  }
            "showall" { $FOS_endResult = ssh $UserName@$($SwitchIP) "clihistory --showall"  }
            Default {$FOS_endResult = ssh $UserName@$($SwitchIP) "clihistory "}
        }
        

        $FOS_endResult
        Write-Debug -Message "Roleconfig: $FOS_endResult"
    }
    end{
        Write-Debug -Message "End block $(Get-Date)"
        Clear-Variable FOS* -Scope Global;
    }

}

function FOS_Fabric_Show {
    <#
    .SYNOPSIS
    Displays fabric membership information.

    .DESCRIPTION
    Use this command to display information about switches in the fabric.
    If the switch is initializing or is disabled, the message "no fabric" is displayed.

    .EXAMPLE
    Use this command to display information about switches in the fabric.
    FOS_Roles_Show -UserName admin -SwitchIP 10.10.10.30

    Displays information about the chassis including chassis WWN and chassis name.
    FOS_Roles_Show -UserName admin -SwitchIP 10.10.10.30 -FOS_Operand chassis

    Displays firmware version details for each domain.
    FOS_Roles_Show -UserName admin -SwitchIP 10.10.10.30 -FOS_Operand version

    Displays the model and serial number of all the switches present in the fabric.
    FOS_Roles_Show -UserName admin -SwitchIP 10.10.10.30 -FOS_Operand model

    Displays the number of paths available to each remote domain. 
    FOS_Roles_Show -UserName admin -SwitchIP 10.10.10.30 -FOS_Operand paths

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
        [ValidateSet("chassis","paths","version","model")]
        [string]$FOS_Operand
    )
    begin{
        Write-Debug -Message "Begin block $(Get-Date)"
    }
    process{
        Write-Debug -Message "Process block $(Get-Date)"
        if($FOS_Operand = ""){
            $FOS_endResult = ssh $UserName@$($SwitchIP) "fabricshow"
        }else{
            $FOS_endResult = ssh $UserName@$($SwitchIP) "fabricshow -$FOS_Operand "
        }  

        $FOS_endResult
        Write-Debug -Message "Roleconfig: $FOS_endResult"
    }
    end{
        Write-Debug -Message "End block $(Get-Date)"
        Clear-Variable FOS* -Scope Global;
    }

}

function FOS_USB_CFG {
    <#
    .SYNOPSIS
    Manages data files on an attached USB storage device.

    .DESCRIPTION
    Use this command to control a USB device attached to the Active CP. 
    When the USB device is enabled, other applications, such as supportSave, firmwareDownload, 
    or configDownload/configUpload can conveniently store and retrieve data from the attached storage device.

    .EXAMPLE
    Enables the USB device. The USB device must be enabled before the list and remove functions are available.
    FOS_USB_CFG -UserName admin -SwitchIP 10.10.10.30 -FOS_Operand enable

    Disables an enabled USB device. This command prevents access to the device until it is enabled again.
    FOS_USB_CFG -UserName admin -SwitchIP 10.10.10.30 -FOS_Operand disable

    To remove a firmware target from the firmware application area:
    FOS_USB_CFG -UserName admin -SwitchIP 10.10.10.30 -FOS_Operand remove -FOS_RM_File v9.1.2

    Lists the content from the USB device or folder path in usbstorage.
    FOS_USB_CFG -UserName admin -SwitchIP 10.10.10.30 -FOS_Operand list

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
        [ValidateSet("enable","disable","remove","list")]
        [string]$FOS_Operand,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("enable","disable","remove","list")]
        [string]$FOS_RM_File
    )
    begin{
        Write-Debug -Message "Begin block $(Get-Date)"
        if(($FOS_Operand -eq "remove") -and($FOS_RM_File -eq "")){Write-Host "If you use the $FOS_Operand operator, you must specify a file or path of the file to be deleted." -ForegroundColor Red ; break}
    }
    process{
        Write-Debug -Message "Process block $(Get-Date)"
        Write-Debug -Message "Username: $Username, SwitchIP $SwitchIP, Operand: $Operand, Path/File to remove: $FOS_RM_File"

        switch ($FOS_Operand) {
            "enable" { $FOS_endResult = ssh $UserName@$($SwitchIP) "usbstorage -e" }
            "disable" { $FOS_endResult = ssh $UserName@$($SwitchIP) "usbstorage -d" }
            "remove" { $FOS_endResult = ssh $UserName@$($SwitchIP) "usbstorage -e && usbstorage -r $FOS_RM_File && usbstorage -d" }
            "list" { $FOS_endResult = ssh $UserName@$($SwitchIP) "usbstorage -e && usbstorage -l && usbstorage -d" }
            Default { Write-Host "You have made a mistake, please check your input: Username: $Username, SwitchIP $SwitchIP, Operand: $Operand, Path/File to remove: $FOS_RM_File" -ForegroundColor Red ; break}
        }
        
        $FOS_endResult
        Write-Debug -Message "Roleconfig: $FOS_endResult"
    }
    end{
        Write-Debug -Message "End block $(Get-Date)"
        Clear-Variable FOS* -Scope Global;
    }

}
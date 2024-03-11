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
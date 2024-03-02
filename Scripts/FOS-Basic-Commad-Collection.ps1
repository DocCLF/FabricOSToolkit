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
            $endResult = ssh $UserName@$($SwitchIP) "tsclockserver"
        }
        elseif($NTP_Show -notlike "show*"){
            $endResult = ssh $UserName@$($SwitchIP) "tsclockserver ""$NTP_Server"" "
        }else {
            $endResult = ssh $UserName@$($SwitchIP) "tsclockserver --$NTP_Show "
        }
        Write-Debug -Message "$endResult"
    }
    end{
            Write-Debug -Message "End block $(Get-Date)"
            Clear-Variable NTP_Se* -Scope Local;
            Write-Host "$endResult" -ForegroundColor Green
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

        $endResult = ssh $UserName@$($SwitchIP) "switchname $SwitchName && chassisname $ChassisName "

        Write-Debug -Message "$endResult"
    }
    end{
            Write-Debug -Message "End block $(Get-Date)"
            Write-Host "$endResult" -ForegroundColor Green
    }    
    
}

function FOS_Fabric_Names {
    <#
    .DESCRIPTION
    Configures fabric name and displays the fabric name parameter.

    .EXAMPLE
    To display the fabric name:
    FOS_Fabric_Names -UserName admin -SwitchIP 10.10.10.30 -Operand show
    
    To set fabric name:
    FOS_Fabric_Names -UserName admin -SwitchIP 10.10.10.30 -Operand set -FabricName newfabric

    To clear the fabric name already set:
    FOS_Fabric_Names -UserName admin -SwitchIP 10.10.10.30 -Operand clear

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
        [string]$Operand,
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$FabricName
    )
    begin{
        Write-Debug -Message "Begin block $(Get-Date)"

        if((($Operand -eq "show") -or ($Operand -eq "clear")) -and ($FabricName -ne "")){
            Write-Host "$Operand does not work in combination with $FabricName " -ForegroundColor Red
            Write-Debug -Message "$Operand and $FabricName are set, leave the func | $(Get-Date)"
            break
        }
    }
    process{
        Write-Debug -Message "Process block $(Get-Date)"

        switch ($Operand) {
            "show" { 
                $endResult = ssh $UserName@$($SwitchIP) "fabricname --$Operand " 
            }
            "clear" { 
                $endResult = ssh $UserName@$($SwitchIP) "fabricname --$Operand " 
            }
            "set" { 
                $endResult = ssh $UserName@$($SwitchIP) "fabricname --$Operand $FabricName" 
            }
            Default {}
        }

        Write-Debug -Message "$endResult"
    }
    end{
            Write-Debug -Message "End block $(Get-Date)"
            Write-Host "$endResult" -ForegroundColor Green
    }    
    
}
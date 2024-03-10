using namespace System.Net

function FOS_Switch_Health_Status {
        <#
        .DESCRIPTION
        Displays the dashboard showing an at-a-glance snapshot of switch health status.

        .EXAMPLE
        Displays a summary of the data collected since midnight of the current day.
        FOS_Switch_Health_Status -UserName admin -SwitchIP 10.10.10.25
        
        Displays a summary and historical data of the errors for 5 rules and last 5 ports.
        FOS_Switch_Health_Status -UserName admin -SwitchIP 10.10.10.25 -Operand all -CreateExportFile yes -ExportFile C:\Temp\
        
        Displays the historical data only.
        FOS_Switch_Health_Status -UserName admin -SwitchIP 10.10.10.25 -Operand history
        

        .LINK
        Brocade® Fabric OS® Command Reference Manual, 9.1.x
        https://techdocs.broadcom.com/us/en/fibre-channel-networking/fabric-os/fabric-os-commands/9-1-x/Fabric-OS-Commands.html
        #>
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$UserName,
        [Parameter(Mandatory,ValueFromPipeline)]
        [ipaddress]$SwitchIP,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("all","history")]
        [string]$Operand,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("yes","no")]
        [string]$CreateExportFile = "no",
        [Parameter(ValueFromPipeline)]
        [string]$ExportFile
    )
    begin{
        Write-Debug -Message "Begin block |$(Get-Date)"
        $OnlineDevice="SwitchStatus-$(Get-Date -Format "yyyy-MM-HH-mm-ss").csv"
        If($CreateExportFile -eq "yes"){
            Write-Host "The default path for the export is $Env:TEMP, if you want to specify your own, please enter it below."
            $ExportFile = Read-Host "Enter a path to the folder for the export "
            if($ExportFile -eq ""){$ExportFile = $Env:TEMP}
        }
        
    }
    process{
        Write-Debug -Message "Process block |$(Get-Date)"
        $result = ssh $UserName@$($SwitchIP) mapsdb --show $Operand
        Start-Sleep -Seconds 3;
        Write-Host "Here the Switch Health Report:`n" -ForegroundColor Green
        $result
        If($CreateExportFile -eq "yes"){
        Export-Csv -Path $ExportFile\$OnlineDevice -InputObject $result -NoTypeInformation
        }
    }
    end{
        Clear-Variable -Name result;
        Write-Debug -Message "End block |$(Get-Date)"
    }
}

function FOS_Switch_SensorShow {
    <#
    .DESCRIPTION
    Use this command to display the current temperature, fan, and power supply status and readings from sensors located on the switch. 
    The actual location of the sensors varies, depending on the switch type.

    .EXAMPLE
    Displays the output without saving to a file
    FOS_Switch_SensorShow -UserName admin -SwitchIP 10.10.10.25

    Displays the output with saving the data in a specific path.
    FOS_Switch_SensorShow -UserName admin -SwitchIP 10.10.10.25 -CreateExportFile yes -ExportFile C:\Temp\

    Displays the output with saving the data in a *. csv file
    FOS_Switch_SensorShow -UserName admin -SwitchIP 10.10.10.25 -CreateExportFile yes

    .LINK
    Brocade® Fabric OS® Command Reference Manual, 9.1.x
    https://techdocs.broadcom.com/us/en/fibre-channel-networking/fabric-os/fabric-os-commands/9-1-x/Fabric-OS-Commands.html
    #>
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$UserName,
        [Parameter(Mandatory,ValueFromPipeline)]
        [ipaddress]$SwitchIP,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("yes","no")]
        [string]$CreateExportFile = "no",
        [Parameter(ValueFromPipeline)]
        [string]$ExportFile
    )
    begin{
        Write-Debug -Message "Begin block |$(Get-Date)"
        $OnlineDevice="SensorShow-$(Get-Date -Format "yyyy-MM-HH-mm-ss").csv"
        If($CreateExportFile -eq "yes"){
            Write-Host "The default path for the export is $Env:TEMP, if you want to specify your own, please enter it below."
            $ExportFile = Read-Host "Enter a path to the folder for the export "
            if($ExportFile -eq ""){$ExportFile = $Env:TEMP}
        }
        
    }
    process{
        Write-Debug -Message "Process block |$(Get-Date)"
        $result = ssh $UserName@$($SwitchIP) "sensorshow"
        Start-Sleep -Seconds 3;
        Write-Host "Here the Sensor Show Report:`n" -ForegroundColor Green
        $result
        If($CreateExportFile -eq "yes"){
        Export-Csv -Path $ExportFile\$OnlineDevice -InputObject $result -NoTypeInformation
        }
    }
    end{
        Clear-Variable -Name result;
        Write-Debug -Message "End block |$(Get-Date)"
    }
}

function FOS_Switch_Show {
    <#
    .DESCRIPTION
    Use this command to display switch, blade, and port status information. Output may vary depending on the switch model.

    .EXAMPLE
    To display switch information
    FOS_Switch_Show -UserName admin -SwitchIP 10.10.10.25

    this should be added
    switchshow -perftxrx

    switchshow -portcount
    switchshow -portname
    
    .LINK
    Brocade® Fabric OS® Command Reference Manual, 9.1.x
    https://techdocs.broadcom.com/us/en/fibre-channel-networking/fabric-os/fabric-os-commands/9-1-x/Fabric-OS-Commands.html
    #>
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$UserName,
        [Parameter(Mandatory,ValueFromPipeline)]
        [ipaddress]$SwitchIP,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("yes","no")]
        [string]$CreateExportFile = "no",
        [Parameter(ValueFromPipeline)]
        [string]$ExportFile
    )
    begin{
        Write-Debug -Message "Begin block |$(Get-Date)"
        # For later Update use the SwitchName instead of SwitchShow
        $OnlineDevice="SwitchShow$(Get-Date -Format "yyyy-MM-HH-mm-ss").csv"
        If($CreateExportFile -eq "yes"){
            Write-Host "The default path for the export is $Env:TEMP, if you want to specify your own, please enter it below."
            $ExportFile = Read-Host "Enter a path to the folder for the export "
            if($ExportFile -eq ""){$ExportFile = $Env:TEMP}
        }
        
    }
    process{
        Write-Debug -Message "Process block |$(Get-Date)"
        $result = ssh $UserName@$($SwitchIP) "switchShow "
        Start-Sleep -Seconds 3;
        Write-Host "Here the Switch Show Report:`n" -ForegroundColor Green
        $result
        If($CreateExportFile -eq "yes"){
        Export-Csv -Path $ExportFile\$OnlineDevice -InputObject $result -NoTypeInformation
        }
    }
    end{
        Clear-Variable -Name result;
        Write-Debug -Message "End block |$(Get-Date)"
    }
}
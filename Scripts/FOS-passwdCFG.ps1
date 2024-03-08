using namespace System.Net

function FOS_Set_passwdCfg {
    <#
    .DESCRIPTION
    Use this command to manage password policies like:
    - Password strength policy
    - Password history policy
    - Password expiration policy
    - Account lockout policy

    Values that are not set are set with the default values!
    All displayable, nonalphanumeric punctuation characters, except the colon (:), are allowed.

    .EXAMPLE
    This Password policy is set to min length of 12 characters with a minimum of 2 lower and 1 upper case alphabetic characters, 2 digits and a max passwordage of 184 days.
    FOS_Set_passwdCfg -UserName admin -SwitchIP 10.10.10.30 -minlength 12 -lowercase 2 -uppercase 1 -digits 2 -maxpasswordage 184

    This Password policy is set to min passwordage of 92 days and max passwordage of 184 days with 3 warnings. 
    FOS_Set_passwdCfg -UserName admin -SwitchIP 10.10.10.30 -minpasswordage 92 -maxpasswordage 184 -warning 3

    Expires the password for all users. Users will be prompted for a password change at the next successful login.
    Expire can only be used alone!
    FOS_Set_passwdCfg -UserName admin -SwitchIP 10.10.10.30 -expire y

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
        [Int32]$charset,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("yes","no")]
        [string]$allowuser = "no",
        [Parameter(ValueFromPipeline)]
        [Int32]$lowercase,
        [Parameter(ValueFromPipeline)]
        [Int32]$uppercase,
        [Parameter(ValueFromPipeline)]
        [Int32]$digits,
        [Parameter(ValueFromPipeline)]
        [Int32]$punctuation,
        [Parameter(ValueFromPipeline)]
        [ValidateLength(10,40)]
        [Int32]$minlength = 10, #The total of -lowercase, -uppercase, -digits, and -punctuation must be less than or equal to the -minlength <value>! Also, the total of -digits and -charset must be less than or equal to the -minlength <value>.
        [Parameter(ValueFromPipeline)]
        [ValidateLength(0,24)]
        [Int32]$history,
        [Parameter(ValueFromPipeline)]
        [ValidateLength(0,40)]
        [Int32]$minDiff,
        [Parameter(ValueFromPipeline)]
        [ValidateLength(0,999)]
        [Int32]$minpasswordage,
        [Parameter(ValueFromPipeline)]
        [ValidateLength(0,999)]
        [Int32]$maxpasswordage,
        [Parameter(ValueFromPipeline)]
        [ValidateLength(0,999)]
        [Int32]$warning,
        [Parameter(ValueFromPipeline)]
        [ValidateLength(0,999)]
        [Int32]$lockoutthreshold,
        [Parameter(ValueFromPipeline)]
        [ValidateLength(0,99999)]
        [Int32]$lockoutduration,
        [Parameter(ValueFromPipeline)]
        [ValidateLength(1,40)]
        [Int32]$repeat,
        [Parameter(ValueFromPipeline)]
        [ValidateLength(1,40)]
        [Int32]$sequence,
        [Parameter(ValueFromPipeline)]
        [ValidateSet(1,0)]
        [Int32]$reverse,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("y","n")]
        [string]$expire = "n"
    )
    begin{
        Write-Debug -Message "Begin block |$(Get-Date)"
        switch ($minlength) {
            {($lowercase + $uppercase + $digits + $punctuation) -gt $_} { 
                Write-Host "The sum of lowercase & uppercase alphabetic characters, numeric digits and punctuation must be less than or equal to the minimum length!`nTheir sum is $($lowercase + $uppercase + $digits + $punctuation) and their minimum length is $minlength ." -ForegroundColor Red
                Write-Debug -Message "$($lowercase + $uppercase + $digits + $punctuation) > $minlength "
                break
            }
            {($digits + $charset) -gt $_}{
                Write-Host "The total of digits and charset must be less than or equal to the minlength $minlength.`nTheir sum is $($charset + $digits) and their minimum length is $minlength ." -ForegroundColor Red
                Write-Debug -Message "$($charset + $digits) > $minlength "
                break
            }
            {$charset -gt $_}{
                Write-Host "The maximum charset on the character set (upper and lowercase letters and special characters) value must be less than or equal to the minlength value.`nThe charset value is $($charset) and the minimum length is $minlength ." -ForegroundColor Red
                Write-Debug -Message "$($charset) > $minlength "
            }
            {($lowercase -or $uppercase) -gt $_}{
                Write-Host "The maximum value of lowercase or uppercase must be less than or equal to the minlength value.`nThe lowercase value is $($lowercase), uppercase value is $($uppercase) and the minimum length is $minlength ." -ForegroundColor Red
                Write-Debug -Message "$($lowercase) , $($uppercase) > $minlength "
                break
            }
            {($digits -or $punctuation) -gt $_}{
                Write-Host "The maximum value of digits or punctuation must be less than or equal to the minlength value.`nThe lowercase value is $($digits), uppercase value is $($punctuation) and the minimum length is $minlength ." -ForegroundColor Red
                Write-Debug -Message "$($digits) , $($punctuation) > $minlength "
                break
            }
            {$minDiff -gt $_}{
                Write-Host "The configuration range of minDiff must be set between 0 to 40 and must be less than the configured minlength value.`nThe minDiff value is $($minDiff) and the minimum length is $minlength ." -ForegroundColor Red
                Write-Debug -Message "$($minDiff) > $minlength "
                break
            }
            Default {Write-Debug -Message "All fine minlength check was successfully completed"}
        }
        if($maxpasswordage -lt $minpasswordage){
            Write-Host "The minpasswordage must be set to a value less than or equal to maxpasswordage, your entry for minpasswordage is $minpasswordage and for maxpasswordage is $maxpasswordage."
            Write-Debug -Message "$($minpasswordage) > $maxpasswordage "
            break
        }else {
            <# Action when all if and elseif conditions are false #>
            Write-Debug -Message "Password age check successfully completed $($minpasswordage) < $maxpasswordage !"
        }
        # show the current password configuration parameters:
        $pw_currentCFG = ssh $UserName@$($SwitchIP) "passwdcfg --showall" 
        $pw_currentCFG
        Write-Debug -Message " $pw_currentCFG " -ErrorAction SilentlyContinue

        $FOS_TempArray=@($charset, $allowuser, $lowercase, $uppercase, $digits, $punctuation, $minlength, $history, $minDiff, $minpasswordage, $maxpasswordage, $warning, $lockoutthreshold, $lockoutduration, $repeat, $sequence, $reverse)
        $FOS_Flag=@("-charset", "-allowuser", "-lowercase", "-uppercase", "-digits", "-punctuation", "-minlength", "-history", "-minDiff", "-minpasswordage", "-maxpasswordage", "-warning", "-lockoutthreshold", "-lockoutduration", "-repeat", "-sequence", "-reverse")
        for ($i = 0; $i -lt $FOS_TempArray.Count; $i++) {
            # Create a list of operands with their values and put them in the correct order
            if([string]::IsNullOrEmpty($FOS_TempArray[$i])){
                Write-Debug -Message "$($FOS_Flag[$i]) $($FOS_TempArray[$i]) are empty"
            }else{
                Write-Debug -Message "$($FOS_Flag[$i]) $($FOS_TempArray[$i])"
                $FOS_List += "$($FOS_Flag[$i]) $($FOS_TempArray[$i]) "
            }
        }
    }
    process{
        Write-Debug -Message "Start of Process block |$(Get-Date)"
        if($expire -eq "y"){
            Write-Host "Expires the password for all users. Users will be prompted for a password change at the next successful login." -ForegroundColor Green
            $pw_newCFG = ssh $UserName@$($SwitchIP) "passwdcfg --set -expire"
        }else{
            $pw_newCFG = ssh $UserName@$($SwitchIP) "passwdcfg --set $FOS_List" 
        }
        $pw_newCFG
        Write-Debug -Message " $pw_newCFG "
    }
    end{
        Write-Debug -Message "End block |$(Get-Date)"
    }
    
}

function FOS_Set_User_passwdCfg {
    <#
    .DESCRIPTION
    Use this command to manage password policies like:
    - Password strength policy
    - Password history policy
    - Password expiration policy
    - Account lockout policy

    Values that are not set are set with the default values!
    All displayable, nonalphanumeric punctuation characters, except the colon (:), are allowed.

    .EXAMPLE
    This Password policy is set to min passwordage of 92 days and max passwordage of 184 days with 3 warnings. 
    FOS_Set_User_passwdCfg -UserName admin -SwitchIP 10.10.10.30 -FOS_user user -minpasswordage 92 -maxpasswordage 184 -warning 3

    Expires the password for all users. Users will be prompted for a password change at the next successful login.
    Expire can only be used alone!
    FOS_Set_User_passwdCfg -UserName admin -SwitchIP 10.10.10.30 -FOS_user user -expire y

    To display the current user password expiration policy parameters:
    FOS_Set_User_passwdCfg -UserName admin -SwitchIP 10.10.10.30 -FOS_user user -Operands showuser

    To delete the password configurations for a specific user:
    FOS_Set_User_passwdCfg -UserName admin -SwitchIP 10.10.10.30 -FOS_user user -Operands deleteuser

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
        [string]$FOS_user,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("showuser","deleteuser")]
        [string]$Operands,
        [Parameter(ValueFromPipeline)]
        [ValidateLength(0,999)]
        [Int32]$minpasswordage = 0,
        [Parameter(ValueFromPipeline)]
        [ValidateLength(0,999)]
        [Int32]$maxpasswordage = 0,
        [Parameter(ValueFromPipeline)]
        [ValidateLength(0,999)]
        [Int32]$warning = 0,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("y","n")]
        [string]$expire = "n"
    )
    begin{
        Write-Debug -Message "Begin block |$(Get-Date)"
        if($maxpasswordage -lt $minpasswordage){
            Write-Host "The minpasswordage must be set to a value less than or equal to maxpasswordage, your entry for minpasswordage is $minpasswordage and for maxpasswordage is $maxpasswordage."
            Write-Debug -Message "$($minpasswordage) > $maxpasswordage "
            break
        }else {
            <# Action when all if and elseif conditions are false #>
            Write-Debug -Message "Password age check successfully completed $($minpasswordage) < $maxpasswordage !"
        }
    }
    process{
        Write-Debug -Message "Start of Process block |$(Get-Date)"
        switch ($Operands) {
            "showuser" { 
                Write-Host "Display the $FOS_user password expiration policy parameters:" -ForegroundColor Green
                $pw_newCFG = ssh $UserName@$($SwitchIP) "passwdcfg --showuser $FOS_user" 
            }
            "deleteuser" { 
                Write-Host "Delete the password configurations for $FOS_user :" -ForegroundColor Red
                $pw_newCFG = ssh $UserName@$($SwitchIP) "passwdcfg --deleteuser $FOS_user" 
            }
            Default {
                if($expire -eq "y"){
                    Write-Host "Expires the password for $FOS_user. $FOS_user will be prompted for a password change at the next successful login." -ForegroundColor Green
                    $pw_newCFG = ssh $UserName@$($SwitchIP) "passwdcfg --setuser $FOS_user -expire"
                }else{
                    $pw_newCFG = ssh $UserName@$($SwitchIP) "passwdcfg --setuser $FOS_user -minpasswordage $minpasswordage -maxpasswordage $maxpasswordage -warning $warning " 
                }
            }
        }
        $pw_newCFG
        Write-Debug -Message " $pw_newCFG "
    }
    end{
        Write-Debug -Message "End block |$(Get-Date)"
    }
    
}

function FOS_Set_Default_passwdCfg {
    <#
    .DESCRIPTION
    Resets all password policies to their default values.

    .EXAMPLE
    FOS_Set_Default_passwdCfg -UserName admin -SwitchIP 10.10.10.30 

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
    )
    begin{
        Write-Debug -Message "Begin block |$(Get-Date)"
        # the current police settings
        $pw_currentCFG = ssh $UserName@$($SwitchIP) "passwdcfg --showall" 
        $pw_currentCFG
        Write-Debug -Message " $pw_currentCFG "
    }
    process{
        Write-Debug -Message "Start of Process block |$(Get-Date)"
        # Resets all password policies to their default values.
        $pw_newCFG = ssh $UserName@$($SwitchIP) "passwdcfg --setdefault"

        $pw_newCFG
        Write-Debug -Message " $pw_newCFG "
    }
    end{
        Write-Debug -Message "End block |$(Get-Date)"
        # the current police settings
        $pw_resetCFG = ssh $UserName@$($SwitchIP) "passwdcfg --showall" 
        $pw_resetCFG
    }
    
}
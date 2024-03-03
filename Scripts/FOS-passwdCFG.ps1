using namespace System.Net

function FOS_Set_passwdCfg {
    <#
    .DESCRIPTION
    Use this command to manage password policies like:
    - Password strength policy
    - Password history policy
    - Password expiration policy
    - Account lockout policy

    .EXAMPLE
    
    FOS_Set_passwdCfg -UserName admin -SwitchIP 10.10.10.30 

    
    FOS_Set_passwdCfg -UserName admin -SwitchIP 10.10.10.30 

    
    FOS_Set_passwdCfg -UserName admin -SwitchIP 10.10.10.30

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
        [Int32]$charset = 0,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("yes","no")]
        [string]$allowuser = "no",
        [Parameter(ValueFromPipeline)]
        [Int32]$lowercase = 1,
        [Parameter(ValueFromPipeline)]
        [Int32]$uppercase = 1,
        [Parameter(ValueFromPipeline)]
        [Int32]$digits = 1,
        [Parameter(ValueFromPipeline)]
        [Int32]$punctuation = 0,
        [Parameter(Mandatory,ValueFromPipeline)]
        [ValidateLength(10,40)]
        [Int32]$minlength = 10, #The total of -lowercase, -uppercase, -digits, and -punctuation must be less than or equal to the -minlength <value>! Also, the total of -digits and -charset must be less than or equal to the -minlength <value>.
        [Parameter(ValueFromPipeline)]
        [ValidateLength(0,24)]
        [Int32]$history =1,
        [Parameter(ValueFromPipeline)]
        [ValidateLength(0,40)]
        [Int32]$minDiff = 0,
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
        [ValidateLength(0,999)]
        [Int32]$lockoutthreshold = 3,
        [Parameter(ValueFromPipeline)]
        [ValidateLength(0,99999)]
        [Int32]$lockoutduration = 5,
        [Parameter(ValueFromPipeline)]
        [ValidateLength(1,40)]
        [Int32]$repeat = 1,
        [Parameter(ValueFromPipeline)]
        [ValidateLength(1,40)]
        [Int32]$sequence = 1,
        [Parameter(ValueFromPipeline)]
        [ValidateSet(1,0)]
        [Int32]$reverse = 1,
        [Parameter()]
        $expire
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
        Write-Debug -Message " $pw_currentCFG "
    }
    process{
        Write-Debug -Message "Start of Process block |$(Get-Date)"
        $pw_newCFG = ssh $UserName@$($SwitchIP) "passwdcfg --set -charset $charset -allowuser $allowuser -lowercase $lowercase -uppercase $uppercase -digits $digits -punctuation $punctuation -minlength $minlength -history $history -minDiff $minDiff -minpasswordage $minpasswordage -maxpasswordage $maxpasswordage -warning $warning -lockoutthreshold $lockoutthreshold -lockoutduration $lockoutduration -repeat $repeat -sequence $sequence -reverse $reverse" 
        $pw_newCFG
        Write-Debug -Message " $pw_newCFG "
    }
    end{
        Write-Debug -Message "End block |$(Get-Date)"
    }
    
}
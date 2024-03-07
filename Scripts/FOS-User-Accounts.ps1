using namespace System.Net

function FOS_User_Show {
    <#
    .DESCRIPTION
    Displays user account information. 
    Only accounts with access permissions compatible with the SecurityAdmin and Admin roles can show information about accounts other than the current login account.

    .EXAMPLE
    Displays information about all accounts.
    FOS_User_Show -UserName admin -SwitchIP 10.10.10.25 FOS_Operands a

    Displays information about all accounts with the specified role.
    FOS_User_Show -UserName admin -SwitchIP 10.10.10.25 FOS_Operands r FOS_RolenName switchadmin

    To see all Roles use 
    FOS_Roles_Show -UserName admin -SwitchIP 10.10.10.25

    Specifies the account login name. When no operand is specified, the command displays the current account information.
    FOS_User_Show -UserName admin -SwitchIP 10.10.10.25 FOS_UserName test

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
    [ValidateSet("a","r")]
    [string]$FOS_Operand,
    [Parameter(ValueFromPipeline)]
    [ValidateSet("admin","basicswitchadmin","fabricadmin","operator","securityadmin","switchadmin","user","zoneadmin","maintenance")]
    [string]$FOS_RolenName,
    [Parameter(ValueFromPipeline)]
    [string]$FOS_UserName

)
begin{
    Write-Debug -Message "Begin block |$(Get-Date)"
    Write-Debug -Message "$UserName,$SwitchIP,$FOS_Operand,$FOS_RolenName,$FOS_UserName"
}
process{
    Write-Debug -Message "Process block |$(Get-Date)"
    switch ($FOS_Operands) {
        "a" { 
            if($FOS_ClassName -ne ""){Write-Host "It is not allowed to use $FOS_Operand with $FOS_UserName!" -ForegroundColor Red ; break}
            $FOS_user_show = ssh $UserName@$($SwitchIP) "userconfig --show -$FOS_Operand" 
        }
        "r" { 
            if($FOS_ClassName -ne ""){Write-Host "It is not allowed to use $FOS_Operand with $FOS_UserName!" -ForegroundColor Red ; break}
            $FOS_user_show = ssh $UserName@$($SwitchIP) "userconfig --show -$FOS_Operand $FOS_RolenName" 
        }
        Default { $FOS_user_show = ssh $UserName@$($SwitchIP) "userconfig --show $FOS_UserName" }
    }

}
end{
    Write-Debug -Message "End block |$(Get-Date)"

    $FOS_user_show
    Write-Debug -Message "Output: $FOS_user_show "

    Clear-Variable FOS* -Scope Local;
}
}

function FOS_User_Add {
    <#
    .DESCRIPTION
    Creates a new user account. The following restrictions apply when you create a user account:
    * You cannot change the role, the Logical Fabric permissions, the home Logical Fabric of any default account.
    * You cannot change the role, the Logical Fabric permissions, or the description of accounts at the same or a higher authorization level.
    * You cannot change the role, the Logical Fabric permissions, or the home Logical Fabric of your own account.
    * Logical Fabric permissions must be a subset of the respective Logical Fabric permissions of the account that creates or modifies a user account.
    * In an Logical Fabric-enabled environment, you can change the role associated with existing Logical Fabrics but you cannot add new Logical Fabrics or delete any existing Logical Fabrics.
    * You cannot use change if the default FID was modified after user creation. --addlf must be used to add newly created Logical Fabrics to user.
    * The account name cannot be the same as an existing user account, a default role, a user-defined role, or a system role. 
      System roles are used by internal switch processes and include the following: smmsp, nobody, udrole, sys, users, utmp. 
      If the specified username already exists, this command fails with an appropriate message. Choose a different username and reissue the command.

    .EXAMPLE
    Creates a new Account with all required operands:
    FOS_User_Add -UserName admin -SwitchIP 10.10.10.25 -FOS_UserName test -FOS_FID 1-128 -FOS_Role admin -FOS_passwd My-super#fancy?PW110

    Creates a new Account with all required operands and Chassisrole:
    FOS_User_Add -UserName admin -SwitchIP 10.10.10.25 -FOS_UserName test -FOS_FID 128 -FOS_Role admin -FOS_passwd My-super#fancy?PW110

    To display all Chassisrole on the switch use FOS_Roles_Show -UserName <admin_acc_name> -SwitchIP <ipaddr>

    .LINK
    Brocade® Fabric OS® Command Reference Manual, 9.1.x
    https://techdocs.broadcom.com/us/en/fibre-channel-networking/fabric-os/fabric-os-commands/9-1-x/Fabric-OS-Commands.html
    #>
    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$UserName,
        [Parameter(Mandatory,ValueFromPipeline)]
        [ipaddress]$SwitchIP,
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$FOS_UserName,
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$FOS_FID,
        [Parameter(Mandatory,ValueFromPipeline)]
        [ValidateSet("admin","basicswitchadmin","fabricadmin","operator","securityadmin","switchadmin","user","zoneadmin","maintenance")]
        [string]$FOS_Role,
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$FOS_passwd,
        [Parameter(ValueFromPipeline)]
        [string]$FOS_ChasRole
    )
    begin{
        Write-Debug -Message "Begin block |$(Get-Date)"
        Write-Debug -Message "$UserName,$SwitchIP,$FOS_UserName,$FOS_FID,$FOS_Role, $FOS_ChasRole,$FOS_passwd"
        if($FOS_UserName -eq (("admin")-or("user")-or("maintenance"))){Write-Host "The following names can neither be deleted nor used, because these are default account names: admin, user, maintenance" -ForegroundColor red; break}
    }
    process{
        Write-Debug -Message "Process block |$(Get-Date)"
        if($FOS_ChasRole -ne ""){
            $FOS_user_add = ssh $UserName@$($SwitchIP) "userconfig --add $FOS_UserName -l $FOS_FID -r $FOS_Role -c $FOS_ChasRole -p $FOS_passwd"
        }else {
            $FOS_user_add = ssh $UserName@$($SwitchIP) "userconfig --add $FOS_UserName -l $FOS_FID -r $FOS_Role -p $FOS_passwd"
        }
        Write-Debug -Message "ssh $UserName $($SwitchIP) userconfig --add $FOS_UserName -l $FOS_FID -r $FOS_Role -c $FOS_ChasRole -p $FOS_passwd"
    }
    end{
        Write-Debug -Message "End block |$(Get-Date)"
        $FOS_user_add
        Clear-Variable FOS* -Scope Local;
    }
}

function FOS_User_Modify {
    <#
    .DESCRIPTION
    Modifies an existing user account. The following restrictions apply when you modify a user account:
    * You cannot change the role, the Logical Fabric permissions, the home Logical Fabric of any default account.
    * You cannot change the role, the Logical Fabric permissions, or the description of accounts at the same or a higher authorization level.
    * You cannot change the role, the Logical Fabric permissions, or the home Logical Fabric of your own account.
    * Logical Fabric permissions must be a subset of the respective Logical Fabric permissions of the account that creates or modifies a user account.
    * In an Logical Fabric-enabled environment, you can change the role associated with existing Logical Fabrics but you cannot add new Logical Fabrics or delete any existing Logical Fabrics.
    * You cannot use change if the default FID was modified after user creation. --addlf must be used to add newly created Logical Fabrics to user.
    * The account name cannot be the same as an existing user account, a default role, a user-defined role, or a system role. 
    System roles are used by internal switch processes and include the following: smmsp, nobody, udrole, sys, users, utmp. 
    If the specified username already exists, this command fails with an appropriate message. Choose a different username and reissue the command.

        .EXAMPLE
    Deletes the specified account from the switch
    FOS_User_Mgmt -UserName admin -SwitchIP 10.10.10.25 -FOS_Operand delete -FOS_UserName testuser

    To change the test account's access permissions for the Virtual Fabrics 100 to ZoneAdmin:
    FOS_User_Mgmt -UserName admin -SwitchIP 10.10.10.25 -FOS_Operand change -FOS_UserName testuser -FOS_FID 100 -FOS_Role zoneadmin

    To change the test account's Password and assign the Operator Role:
    FOS_User_Mgmt -UserName admin -SwitchIP 10.10.10.25 -FOS_Operand change -FOS_UserName testuser FOS_passwd myfancyPW! -FOS_Role operator

    For more Infos around Default Fabric OS Roles view Brocade techdocs!

    .LINK
    Brocade® Fabric OS® Command Reference Manual, 9.1.x
    https://techdocs.broadcom.com/us/en/fibre-channel-networking/fabric-os/fabric-os-commands/9-1-x/Fabric-OS-Commands.html
    #>

    param (
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$UserName,
        [Parameter(Mandatory,ValueFromPipeline)]
        [ipaddress]$SwitchIP,
        [Parameter(Mandatory,ValueFromPipeline)]
        [ValidateSet("change","delete")]
        [string]$FOS_Operand,
        [Parameter(Mandatory,ValueFromPipeline)]
        [string]$FOS_UserName,
        [Parameter(ValueFromPipeline)]
        [string]$FOS_FID,
        [Parameter(ValueFromPipeline)]
        [ValidateSet("admin","basicswitchadmin","fabricadmin","operator","securityadmin","switchadmin","user","zoneadmin","maintenance")]
        [string]$FOS_Role,
        [Parameter(ValueFromPipeline)]
        [string]$FOS_passwd,
        [Parameter(ValueFromPipeline)]
        [string]$FOS_ChasRole
    )
    begin{
        Write-Debug -Message "Begin block |$(Get-Date)"
        Write-Debug -Message "$UserName,$SwitchIP,$FOS_Operand,$FOS_UserName,$FOS_FID,$FOS_Role,$FOS_passwd"
        if(($FOS_UserName -eq (("admin")-or("user")-or("maintenance")))-and ($FOS_Operand -eq "delete")){Write-Host "The following names can neither be deleted, because these are default accounts: admin, user, maintenance" -ForegroundColor red; break}
        # To be on the safe side, the user is shown a list of all accounts here.
        FOS_User_Show -UserName $UserName -SwitchIP $SwitchIP -FOS_Operand a

        $FOS_TempArray=@($FOS_FID ,$FOS_Role ,$FOS_ChasRole,$FOS_passwd)
        $FOS_Flag=@("-l","-r","-c","-p")
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
        Write-Debug -Message "Process block |$(Get-Date)"
        switch ($FOS_Operand) {
            "change" { $FOS_user_add = ssh $UserName@$($SwitchIP) "userconfig --$FOS_Operand $FOS_UserName $FOS_List" }
            "delete" { $FOS_user_add = ssh $UserName@$($SwitchIP) "userconfig --$FOS_Operand $FOS_UserName " }
            Default {Write-Host "Oops something went wrong, try it again with the -debug flag at the end." -ForegroundColor Red}
        }
        
    }
    end{
        Write-Debug -Message "End block |$(Get-Date)"
        $FOS_user_add
        Write-Debug -Message "Resault: $FOS_user_add |$(Get-Date)"
        Clear-Variable FOS* -Scope Local;
    }
}

<# 
At this time this is only a test or idea how to create a FOS Dashboard based on the FOS-Functions.
This File needs the PSwriteHTML Module!
#>


# there a lot of "errors" in combination with substring Parameter, thats why "silentlycontinue"
$ErrorActionPreference="SilentlyContinue"

# Hashtable for basic switch infos
$FOS_SwBasicDetails =@{}

$FOS_advInfo = Get-Content -Path ".\ip_vers.txt" |Select-Object -Skip 2

# Select all needed Infos
$FOS_FW_Info = ($FOS_advInfo | Select-String -Pattern '([v?][\d]\.[\d+]\.[\d]\w)$' -AllMatches).Matches.Value |Select-Object -Unique
$FOS_IP_AddrCFG = ($FOS_advInfo | Select-String -Pattern '(?:[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3});','(?:[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})').Matches.Value |Select-Object -Unique
$FOS_DHCP_CFG = (($FOS_advInfo | Select-String -Pattern '\s(\w+)$' -AllMatches).Matches.Value |Select-Object -Unique).Trim()

# add the needed Infos into the Hashtable
$FOS_SwBasicDetails.Add('FOS Version',$FOS_FW_Info)
$FOS_SwBasicDetails.Add('Ethernet IP Address',$FOS_IP_AddrCFG[0])
$FOS_SwBasicDetails.Add('Ethernet Subnet mask',$FOS_IP_AddrCFG[1])
$FOS_SwBasicDetails.Add('Gateway IP Address',$FOS_IP_AddrCFG[2])
$FOS_SwBasicDetails.Add('DHCP',$FOS_DHCP_CFG)



# Used for some vars an other stuff
$FOS_pbs_temp = plink insight@192.168.107.40 -pw Insight0Mon -batch "portbuffershow" 
$FOS_swsh_temp = Get-Content -Path ".\swsh.txt"
$FOS_SwBasicPortDetails=@()
$FOS_usedPorts =@()
<#switchshow#>
foreach($FOS_linebyLine in $FOS_swsh_temp){

        # select some Basic Switch Infos
        $FOS_temp += Select-String -InputObject $FOS_linebyLine -Pattern 'switchName:\s(.*)$','switchType:\s(.*)$','switchState:\s(.*)$','switchRole:\s(.*)$','switchDomain:\s(.*)$','switchWwn:\s(.*)$','Fabric Name:\s(.*)$' |ForEach-Object {$_.Matches.Groups[1].Value}
        
        # workaround for zoning info, becaus there is a prob with the regex or anything else, the problem come only with WWN combination
        if([string]::IsNullOrEmpty($FOS_tempzone)){
            $FOS_tempzone += Select-String -InputObject $FOS_linebyLine -Pattern '\D\((\w+)\)$' |ForEach-Object {$_.Matches.Groups[1].Value}
        }

        # Split FOS_temp in parts, the regex \s means any whitespace character, + means one or more
        $FOS_SwInfo = $FOS_temp.Trim() -split ("\s+")

        # make the Switch Typ readable without using google ;)
        if($FOS_SwInfo[1] -ne ""){
            switch ($FOS_SwInfo[1]) {
                {$_ -like "173*"}  { $FOS_SwHw = "Brocade G630" }
                Default {$FOS_SwHw = $FOS_SwInfo[1]}
            }
        }
        
        # add more Basic Infos of the switch to the Hashtable
        $FOS_SwBasicDetails=@{
            'Swicht Name'=$FOS_SwInfo[0]
            'Switch Type'=$FOS_SwInfo[1]
            'Brocade Product Name'=$FOS_SwHw
            'Switch State'=$FOS_SwInfo[2]
            'Switch Role'=$FOS_SwInfo[3]
            'Switch Domain'=$FOS_SwInfo[4]
            'Switch WWN'=$FOS_SwInfo[5]
            'Fabric Name'=$FOS_SwInfo[6]
            'Active ZonenCFG'=$FOS_tempzone
        }
        
        # Build the Portsection of switchshow
        if($FOS_linebyLine -match '^\s+\d+'){
            $FOS_SWsh = "" | Select-Object Index,Port,Address,Media,Speed,State,Proto,PortConnect
            $FOS_SWsh.Index = $FOS_linebyLine.Substring(0,4).Trim()
            $FOS_SWsh.Port = $FOS_linebyLine.Substring(5,5).Trim()
            $FOS_SWsh.Address = $FOS_linebyLine.Substring(10,8).Trim()
            $FOS_SWsh.Media = $FOS_linebyLine.Substring(20,4).Trim()
            $FOS_SWsh.Speed = $FOS_linebyLine.Substring(25,5).Trim()
            $FOS_SWsh.State = $FOS_linebyLine.Substring(34,10).Trim()
            $FOS_SWsh.Proto = $FOS_linebyLine.Substring(45,4).Trim()
            $FOS_SWsh.PortConnect = $FOS_linebyLine.Substring(50).Trim()
            $FOS_SwBasicPortDetails += $FOS_SWsh
        }
        # if the Portnumber is not empty and there is a SFP pluged in, push the Port in the FOS_usedPorts array
        if(($FOS_SWsh.Port -ne "") -and ($FOS_SWsh.Media -eq "id")){$FOS_usedPorts += $FOS_SWsh.Port}
}

<#Porterrshow#>
$FOS_perrsh_temp = Get-Content -Path ".\porteersh.txt" |Select-Object -Skip 2
$FOS_usedPortsfiltered =@()
foreach ($FOS_port in $FOS_perrsh_temp){
    #create a var and pipe some objects in
    $FOS_PortErr = "" | Select-Object Port,frames_tx,frames_rx,enc_in,crc_err,crc_g_eof,too_shrt,too_long,bad_eof,enc_out,disc_c3,link_fail,loss_sync,loss_sig,f_rejected,f_busied,c3timeout_tx,c3timeout_rx,psc_err,uncor_err
    #select the ports
    $FOS_PortErr.Port = $FOS_port.Substring(0,3).Trim()
    #check if the port is "active", if it is fill the objects
    foreach($FOS_usedPortstemp in $FOS_usedPorts){
        if($FOS_PortErr.Port -eq $FOS_usedPortstemp){
        $FOS_PortErr.frames_tx = $FOS_port.Substring(6,6).Trim()
        $FOS_PortErr.frames_rx = $FOS_port.Substring(13,6).Trim()
        $FOS_PortErr.enc_in = $FOS_port.Substring(20,6).Trim()
        $FOS_PortErr.crc_err = $FOS_port.Substring(27,6).Trim()
        $FOS_PortErr.crc_g_eof = $FOS_port.Substring(35,6).Trim()
        $FOS_PortErr.too_shrt = $FOS_port.Substring(41,6).Trim()
        $FOS_PortErr.too_long = $FOS_port.Substring(48,6).Trim()
        $FOS_PortErr.bad_eof = $FOS_port.Substring(55,6).Trim()
        $FOS_PortErr.enc_out = $FOS_port.Substring(63, 6).Trim()
        $FOS_PortErr.disc_c3 = $FOS_port.Substring(69,6).Trim()
        $FOS_PortErr.link_fail = $FOS_port.Substring(75,6).Trim()
        $FOS_PortErr.loss_sync = $FOS_port.Substring(82,6).Trim()
        $FOS_PortErr.loss_sig = $FOS_port.Substring(90,6).Trim()
        $FOS_PortErr.f_rejected = $FOS_port.Substring(97,6).Trim()
        $FOS_PortErr.f_busied = $FOS_port.Substring(104, 6).Trim()
        $FOS_PortErr.c3timeout_tx = $FOS_port.Substring(111, 6).Trim()
        $FOS_PortErr.c3timeout_rx = $FOS_port.Substring(117, 6).Trim()
        $FOS_PortErr.psc_err = $FOS_port.Substring(124, 6).Trim()
        $FOS_PortErr.uncor_err = $FOS_port.Substring(131).Trim()
        $FOS_usedPortsfiltered += $FOS_PortErr
        }
    }
}


# $test = ssh admin@192.168.249.81 "portbuffershow" 
$FOS_Temp_var = $FOS_pbs_temp |Select-Object -Skip 3

<#Portbuffershow#>
$FOS_pbs_temp = plink insight@192.168.107.40 -pw Insight0Mon -batch "portbuffershow" 
$FOS_pbs_temp = Get-Content -Path ".\pbs_l.txt"
$FOS_Temp_var = $FOS_pbs_temp |Select-Object -Skip 3
$FOS_pbs =@()
foreach ($FOS_thisLine in $FOS_Temp_var) {
    #create a var and pipe some objects in and fill them with some data
    $FOS_PortBuff = "" | Select-Object UsedPort,PortType,LX_Mode,Max_ResvBuffer,Tx,Rx,Bufffer_Usage,Buffer_Needed,Link_Distance,Remaining_Buffers
    $FOS_PortBuff.UsedPort = $FOS_thisLine.Substring(0,4).Trim()
    $FOS_PortBuff.PortType = $FOS_thisLine.Substring(11,4).Trim()
    $FOS_PortBuff.LX_Mode = $FOS_thisLine.Substring(17,4).Trim()
    $FOS_PortBuff.Max_ResvBuffer = $FOS_thisLine.Substring(27,7).Trim()
    $FOS_PortBuff.Tx = $FOS_thisLine.Substring(36,14).Trim()
    $FOS_PortBuff.Rx = $FOS_thisLine.Substring(50,14).Trim()
    $FOS_PortBuff.Buffer_Usage = $FOS_thisLine.Substring(67,6).Trim()
    $FOS_PortBuff.Buffer_Needed = $FOS_thisLine.Substring(75,7).Trim()
    $FOS_PortBuff.Link_Distance = $FOS_thisLine.Substring(85,6).Trim(" ","-")
    $FOS_PortBuff.Remaining_Buffers = $FOS_thisLine.Substring(95, 6).Trim()
    $FOS_pbs += $FOS_PortBuff

}

Dashboard -Name "Brocade Testboard" -FilePath $Env:TEMP\Dashboard.html {
    Tab -Name "Info of $($FOS_SwInfo[0])" {
        Section -Name "More Info 1" -Invisible {
            Section -Name "Basic Information" {
                Table -HideFooter -HideButtons -DisablePaging -DisableSearch -DataTable $FOS_SwBasicDetails
            }
            Section -Name "Basic Port Information" {
                Table -PagingLength 10 -HideFooter -DataTable $FOS_SwBasicPortDetails
            }
        }
        Section -Name "Port Info" -Invisible{
            Section -Name "Port Error Show" -CanCollapse {
                Table -HideFooter -DataTable $FOS_usedPortsfiltered
            }
            Section -name "Port Buffer Show" -CanCollapse   {
                Table -HideFooter -DataTable $FOS_pbs
            }
        }
    }
    Tab -Name "Info of Switch Name 2" {

    }
    Tab -Name "Info of Switch Name 3" {

    }
    Tab -Name "Info of Switch Name 4" {

    }
} -Show



Clear-Variable FOS* -Scope Global;

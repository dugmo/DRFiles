 <#
 Updated:     2018-06-13 by Doug Seiler

 Edits:       Script will now create account and OU if they don't already exist.

 Usage:       $Account is account name.  $TargetOU is name of the OU and will be placed in the CORP OU.



 Script name: Configure-OUPermissions

 Created:     2013-01-08

 Version:     1.0

 Author       Mikael Nystrom and Johan Arwidmark       

 Homepage:    http://www.deploymentfundamentals.com



 Disclaimer:

 This script is provided "AS IS" with no warranties, confers no rights and 

 is not supported by the authors or DeploymentArtist.



 Author - Mikael Nystrom

 Twitter: @mikael_nystrom

 Blog   : http://deploymentbunny.com



 Author - Johan Arwidmark

 Twitter: @jarwidmark

 Blog   : http://deploymentresearch.com

 #>



 Param

 (

 [parameter(mandatory=$true,HelpMessage="Please, provide a name.")][ValidateNotNullOrEmpty()]$Account,

 [parameter(mandatory=$true,HelpMessage="Please, provide the OU to be used.")][ValidateNotNullOrEmpty()]$TargetOU

 )



 # Start logging to screen

 Write-host (get-date -Format u)" - Starting"



 # This i what we typed in

 Write-host "Account to search for is" $Account

 Write-Host "OU to search for is" $TargetOU



 $CurrentDomain = Get-ADDomain

 # If account does not exist, create it in Users OU

 if(!(Get-ADUser -Filter {SamAccountName -eq $Account})){
 Write-Host "$Account does not exist.  Creating it."
 New-ADUser -Name $Account -AccountPassword (ConvertTo-SecureString "P@ssw0rd" -AsPlainText -Force) -PasswordNeverExpires 1 -Enabled 1 -Description "ConfigMgr Domain Join Account"
 }

 $OrganizationalUnitDN = "OU="+$TargetOU+",OU=CORP,"+$CurrentDomain

 # If OU does not exist, create it in CORP OU

 if(!([adsi]::Exists("LDAP://$OrganizationalUnitDN"))){
 Write-Host "$TargetOU does not exist.  Creating it."
 New-ADOrganizationalUnit -Name $TargetOU -Path "OU=CORP,$CurrentDomain"
 }


 $SearchAccount = Get-ADUser $Account



 $SAM = $SearchAccount.SamAccountName

 $UserAccount = $CurrentDomain.NetBIOSName+"\"+$SAM



 Write-Host "Account is = $UserAccount"

 Write-host "OU is =" $OrganizationalUnitDN



 dsacls.exe $OrganizationalUnitDN /G $UserAccount":CCDC;Computer" /I:T | Out-Null

 dsacls.exe $OrganizationalUnitDN /G $UserAccount":LC;;Computer" /I:S | Out-Null

 dsacls.exe $OrganizationalUnitDN /G $UserAccount":RC;;Computer" /I:S | Out-Null

 dsacls.exe $OrganizationalUnitDN /G $UserAccount":WD;;Computer" /I:S  | Out-Null

 dsacls.exe $OrganizationalUnitDN /G $UserAccount":WP;;Computer" /I:S  | Out-Null

 dsacls.exe $OrganizationalUnitDN /G $UserAccount":RP;;Computer" /I:S | Out-Null

 dsacls.exe $OrganizationalUnitDN /G $UserAccount":CA;Reset Password;Computer" /I:S | Out-Null

 dsacls.exe $OrganizationalUnitDN /G $UserAccount":CA;Change Password;Computer" /I:S | Out-Null

 dsacls.exe $OrganizationalUnitDN /G $UserAccount":WS;Validated write to service principal name;Computer" /I:S | Out-Null

 dsacls.exe $OrganizationalUnitDN /G $UserAccount":WS;Validated write to DNS host name;Computer" /I:S | Out-Null

 dsacls.exe $OrganizationalUnitDN

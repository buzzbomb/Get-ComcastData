   clear-host
    
Function Send-Email ($data)
{ 
$time=Get-Date
$cap="300"

$remainder=[int]$cap-[int]$dataUsed

$emailSmtpServer = "smtp.live.com" 
$emailSmtpServerPort = "587"
$emailSmtpUser =  "<sample email>@outlook.com"
$emailSmtpPass = "<password>"
 
$emailFrom =  "<sample email>@outlook.com"
$emailTo =  "<sample email>@outlook.com"
 
$emailMessage = New-Object System.Net.Mail.MailMessage( $emailFrom , $emailTo )
$emailMessage.Subject = "Data usage results for $time"
$emailMessage.IsBodyHtml = $true
$emailMessage.Body = @"
<p>You have used<strong> $data </strong> of your $cap cap.</p>
<p>There are
"@
 
$SMTPClient = New-Object System.Net.Mail.SmtpClient( $emailSmtpServer , $emailSmtpServerPort )
$SMTPClient.EnableSsl = $true
$SMTPClient.Credentials = New-Object System.Net.NetworkCredential( $emailSmtpUser , $emailSmtpPass );
 
$SMTPClient.Send( $emailMessage )
} 


$pattern="([0-9]{1,3}GB of [0-9]{1,3}GB as of (January|Febuary|March|April|May|June|July|August|September|October|November|December) [0-9]{1,2}\, [0-9]{4})"
$fileLocation="$env:userprofile\My Documents\comcastPull.txt"
$username = "<sample email>@outlook.com" 
$password = "<password>" 
$ie = New-Object -com InternetExplorer.Application 
$ie.visible=$false
$ie.navigate($url) 
while($ie.ReadyState -ne 4) {start-sleep -m 100} 
$ie.document.getElementById("user").value= "$username" 
$ie.document.getElementById("passwd").value = "$password" 
$ie.document.getElementById("signin").submit()
start-sleep 20 
#This is the ID, Historical
#getElementById("main_0_rptInternet_ctl00_usageMeterHolder")
$ie.document.body.innerText > $fileLocation
$pulledConetent = gc $fileLocation
Remove-Item $fileLocation
$dataUsed = (($pulledConetent | Select-String -Pattern $pattern) -split " " | Select-Object -first 1) -split "GB"

Send-Email $dataUsed




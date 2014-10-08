
Function Send-Email ($from, $to, $subject,$message)
{ 
<#
  .SYNOPSIS
  Sends an email to and from a given address
  .DESCRIPTION
  Takes input of from, to, subject and message and using the SmtpClient in .Net
  sends an email to the given 'to' user
  .EXAMPLE
  Send-Email $emailFrom $emailTo $subject $body
  .PARAMETER from
  The email will be sent to this user
  .PARAMETER to
  The email is from this user
  .PARAMETER subject
  This is the subject of the email
  .PARAMETER message
  This is the email body
  #>

    $time=Get-Date
   
    $emailSmtpServer = "smtp.live.com" 
    $emailSmtpServerPort = "587"
    $emailSmtpUser =  "<sample email>@outlook.com"
    $emailSmtpPass = "<password>"
     
    
     
    $emailMessage = New-Object System.Net.Mail.MailMessage( $from , $to )
    $emailMessage.Subject = $subject 
    $emailMessage.IsBodyHtml = $true
    $emailMessage.Body = $body
     
    $SMTPClient = New-Object System.Net.Mail.SmtpClient( $emailSmtpServer , $emailSmtpServerPort )
    $SMTPClient.EnableSsl = $true
    $SMTPClient.Credentials = New-Object System.Net.NetworkCredential( $emailSmtpUser , $emailSmtpPass );
    
    if($SMTPClient.Send( $emailMessage ))
    {
        return true
    }
    else
    {
        return false
    }
    
} 





function Get-DataUsage($username, $password){
<#
  .SYNOPSIS
  REGEX's the data from comcastcats website
  .DESCRIPTION
  Takes input of a comcast account and gets the data usage by regexuing the MyServices page.
  .EXAMPLE
  Get-DataUsage Tom SecretPassW%rd
    This will retrieve Toms data usage.
  .PARAMETER username
  Your comcast username
  .PARAMETER password
  Your Comcast password
  #>

    $pattern="([0-9]{1,3}GB of [0-9]{1,3}GB as of (January|Febuary|March|April|May|June|July|August|September|October|November|December) [0-9]{1,2}\, [0-9]{4})"

    $url="https://customer.comcast.com/Secure/MyServices/"
    $ie = New-Object -com InternetExplorer.Application 
    $ie.visible=$false
    $ie.navigate($url) 
    while($ie.ReadyState -ne 4) {start-sleep -m 100} 
    $ie.document.getElementById("user").value= "$username" 
    $ie.document.getElementById("passwd").value = "$password" 
    $ie.document.getElementById("signin").submit()
    start-sleep 20
    $dataUsed = ((($ie.document.body.innerText| Select-String -Pattern $pattern) -split " " | Select-Object -first 1) -split "GB")

    if($dataUsed)
    {
        return $dataUsed
    }
    else
    {
        return false
    }

}



$comcastUsername = "<sample email>@outlook.com" #Your comcast username
$comcastPassword = "<password>" #Your comcast password

$dataUsed = Get-DataUsage $comcastUsername $comcastPassword


$emailFrom =  "<sample email>@outlook.com"
$emailTo =  "<sample email>@outlook.com"
$subject = "Data usage results for $time"

if($pulledContent)
{
    $body = @"
        <p>You have used<strong> $dataUsed </strong>GB of your<strong> $cap </strong>GB cap.</p>
        <p>There are <insert maths>GBs remaining.</p>
        <p>At your current rate of consumption you have <insert maths> days left before hitting the pay cap.</P>
"@
}
else
{
    $body = @"
    <p>There was an error in retrieving your comcast usage information.</p>
"@   
}


Send-Email $emailFrom $emailTo $subject $body




<#
.SYNOPSIS

Copy the PowerShell script desired folder
Set up Azure Service Principal - Contributor access on the Subscription: https://blog.jongallant.com/2017/11/azure-rest-apis-postman/
Open PowerShell with 'Run As administrator Privileges'
Run the below command to bypass the execution policy  and accept -Y
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Change the directory to the PowerShell script copied folder in first step.
        cd  'PowerShellScriptFolderPath'
Execute the command to perform the different mentioned operations on Logic App
.\LogicAppUtility.ps1 -ClientId 'Enter ClientId' -TenantId 'Enter TenantId' -Secret 'Enter Secret' -SubscriptionId 'Enter Subscription Id' -ResourceGroupName 'Enter resource Group Name' -LogicAppName 'Enter Logic App Name' -Operation 'BulkCancel' -StartTime '2020-11-02T16:33:00.000Z' -EndTime '2020-11-02T16:38:00.000Z’
 Validate the text file gets created in the same folder for list of run ids executed.


.DESCRIPTION:

 Manages below Logic App operations:
1.BulkCancel - Cancel running instances
2.BulkResubmitFailedRuns - Resubmits failed runs
3.BulkResubmitCancelledRuns - Resubmits cancelled runs
4.BulkResubmitSucceededRuns - Resubmits Succeeded runs

.PARAMETERs
  
S.No  Parameter Name	   Mandatory	     Comments
	1	Client Id	        No	         The application /Client Id of your App Service Principal
	2	Tenant Id	        No	         Tenant Id of Azure AD or App Service Principal 
	3	Client Secret	    No	         Secret of your App Service Principal
	4	Subscription Id	    Yes	         Subscription Id where Logic App present
	5 ResourceGroupName     Yes	         Resource group Name in which Logic App is present
	6	Logic App Name	    Yes	         Name of your Logic App
	7	Operation	        Yes	         Allowed Values are 
				                           • BulkCancel - Cancel running instances
				                           • BulkResubmitFailedRuns - Resubmits failed runs
				                           • BulkResubmitCancelledRuns - Resubmits cancelled runs
				                           • BulkResubmitSucceededRuns - Resubmits Succeeded runs
	8	StartTime	        No	         If present all above operations will be performed on the runs started from this time.
				                           The Timestamp must be in UTC.				  
				                           Ex: 2020-11-02T16:33:00.000Z
	9	EndTime	            No             You can include the EndTime along with StartTime if you want to perform above operations between specific timestamps.
				                          Note:
				                          It is invalid without StartTime. 

.OUTPUTS
  Log file gets created in PowqerShell script folder
.NOTES
 
  Author:         Veera Reddy Gangala
  Creation Date:  2020-11-04
  Purpose/Change: Initial script development
  
.EXAMPLE

  .\LogicAppUtility.ps1 -ClientId 'Enter ClientId' -TenantId 'Enter TenantId' -Secret 'Enter Secret' -SubscriptionId 'Enter Subscription Id' -ResourceGroupName 'Enter resource Group Name' -LogicAppName 'Enter Logic App Name' -Operation 'BulkCancel' -StartTime '2020-11-02T16:33:00.000Z' -EndTime '2020-11-02T16:38:00.000Z’
 Validate the text file gets created in the same folder for list of run ids executed.
#>

param ([Parameter(Mandatory=$false)] $ClientId ,[Parameter(Mandatory=$false)] $TenantId,[Parameter(Mandatory=$false)] $Secret,[Parameter(Mandatory=$true)] $SubscriptionId,[Parameter(Mandatory=$true)] $ResourceGroupName,[Parameter(Mandatory=$true)] $LogicAppName, [Parameter(Mandatory=$false)] $StartTime , [Parameter (Mandatory=$true)] $Operation,[Parameter (Mandatory=$false)] $EndTime )

#. OAuth Token Function

function GetOAuthToken
{
param( [string]$TenantId,[string] $ClientId, [String]$Secret)

#Get OAuth token using Service Principal

try
{

$url='https://login.microsoftonline.com/'+$TenantId+'/oauth2/token'

$body='grant_type=client_credentials&client_id='+$ClientId+'&resource=https://management.azure.com&client_secret='+$Secret

$ContentType='application/x-www-form-urlencoded'

#Call OAUth URL for token

$result= Invoke-RestMethod -Method 'POST' -Uri $url -Body $body -ContentType $ContentType 

$OAuthtoken=$result.access_token

Write-Output $OAuthtoken
}

catch
{
 New-Item '.\ErrorFile.txt'
Add-Content '.\ErrorFile.txt' "An error occured while generating OAuth token, error: $($PSItem.ToString())" 
throw "An error occured while generating OAuth token, error: $($PSItem.ToString())" 
}
}


#Get Run Ids of Logic App for given Criteria
function GetRunIds
{
param( [parameter (Mandatory= $true)] $Headers, [parameter (Mandatory= $false)] $nextlink,  [parameter (Mandatory= $false)] $OperationName , [parameter (Mandatory= $false)] $StartTime )

try
{
if($nextlink -eq $null)
{

$TaskName

if($OperationName -eq 'BulkResubmitFailedRuns')
{
$TaskName='Failed'
}

elseIf($OperationName -eq 'BulkCancel')
{
$TaskName='Running'
}
elseIf($OperationName -eq 'BulkResubmitCancelledRuns')
{
$TaskName='Cancelled'
}
elseif($OperationName -eq 'BulkResubmitSucceededRuns')
{
$TaskName='Succeeded'
}
else
{
write-host Invalid Operation Name: Allowed values are [BulkResubmitFailedRuns/BulkResubmitCancelledRuns/BulkCancel/BulkResubmitSucceededRuns] -ForegroundColor Red

Exit $true
}
if(($StartTime -ne $null) -and ($EndTime -ne $null))
 {
 $url='https://management.azure.com/subscriptions/'+$SubscriptionId+'/resourceGroups/'+$ResourceGroupName+'/providers/Microsoft.Logic/workflows/'+$LogicAppName+'/runs?api-version=2016-06-01&$filter=(Status eq '''+$TaskName+''' and startTime ge '+$StartTime+' and startTime le '+$EndTime+' )'
}
elseif(($StartTime -ne $null) -and ($EndTime -eq $null))
 {
$url='https://management.azure.com/subscriptions/'+$SubscriptionId+'/resourceGroups/'+$ResourceGroupName+'/providers/Microsoft.Logic/workflows/'+$LogicAppName+'/runs?api-version=2016-06-01&$filter=(Status eq '''+$TaskName+''' and startTime ge '+$StartTime+')'
}
else
{
$url='https://management.azure.com/subscriptions/'+$SubscriptionId+'/resourceGroups/'+$ResourceGroupName+'/providers/Microsoft.Logic/workflows/'+$LogicAppName+'/runs?api-version=2016-06-01&$filter=(Status eq '''+$TaskName+''')'
}
$result= Invoke-RestMethod -Method 'GET' -Uri $url -Headers $headers 
}

else 
{
$result= Invoke-RestMethod -Method 'GET' -Uri $nextlink -Headers $headers 
}

Write-Output $result

}

Catch
{
New-Item '.\ErrorFile.txt'
Add-Content '.\ErrorFile.txt' "An error occured while fecthing the RunIds with error: $($PSItem.ToString())"
throw "An error occured while fecthing the RunIds with error: $($PSItem.ToString())"
}
}

#Cance Run 
function CancelRun 
{
param ($headers, $SubscriptionId,  $ResourceGroupName, $LogicAppName, $RunId, $Filepath , $RunIdStartTime)
try
{
$cancelrunurl= 'https://management.azure.com/subscriptions/'+$SubscriptionId+'/resourceGroups/'+$ResourceGroupName+'/providers/Microsoft.Logic/workflows/'+$LogicAppName+'/runs/'+$RunId+'/cancel?api-version=2016-06-01'

$output=Invoke-RestMethod -Method 'POST' -Uri $cancelrunurl -Headers $headers 

Add-Content $Filepath "$RunId       $RunIdStartTime"

}
catch
{
Add-Content $Filepath "Error occured while cancelling the run: $RunId, StartTime:$RunIdStartTime  with error: $($PSItem.ToString())"
throw "Error occured while cancelling the run $RunId with error: $($PSItem.ToString())"
}
 }

 #Resibmit the specified Run
function ResubmitRun
{
param ($headers, $SubscriptionId, $ResourceGroupName,  $LogicAppName,$RunId, $Filepath , $RunIdStartTime)

try
{
$Resubmiturl= 'https://management.azure.com/subscriptions/'+$SubscriptionId+'/resourceGroups/'+$ResourceGroupName+'/providers/Microsoft.Logic/workflows/'+$LogicAppName+'/triggers/'+$TriggerName+'/histories/'+$RunId+'/resubmit?api-version=2016-06-01'

$output= Invoke-RestMethod -Method 'POST' -Uri $Resubmiturl -Headers $headers
 Add-Content $Filepath "$RunId       $RunIdStartTime"
 }
 catch
 {
 Add-Content $Filepath "An error occured while Resubmitting the RunId : $RunId, StartTime:$RunIdStartTime with error: $($PSItem.ToString())"
 throw "An error occured while Resubmitting the RunId $RunId with error: $($PSItem.ToString())"
 }
}

try
{
Write-Host 'Do you want to use User sign-in or Azure AD App registration details for authentication: Select 1 -for user sign-in and Select 2 -for App resgitration details' -ForegroundColor White
$confirmation = Read-Host " Confirm [1/2]"

if($confirmation -eq 1)
{
az login 
$token = az account get-access-token 
$OAuthtoken = az account get-access-token --query 'accessToken' -o tsv
}
elseif ($confirmation -eq 2)
{
$OAuthtoken= GetOAuthToken -TenantId $TenantId -ClientId $ClientId -Secret $Secret
}
else
{
write-host Invalid Operation Name: Allowed values are [BulkResubmitFailedRuns/BulkResubmitCancelledRuns/BulkCancel/BulkResubmitSucceededRuns] -ForegroundColor Red
Exit $true
}



# Construct Header for Authorization
$headers = @{
    'Authorization' = 'Bearer '+$OAuthtoken}

#Set dummy for the first time to get in loop, however this is handled within loop to construct URl
$nextlink ='Dummy'
$i=0
$Filename
do
{
# Check if first iteration to make intial REST call.

if($i -eq 0)
{
$result=GetRunIds -Headers $headers -OperationName $Operation -StartTime $StartTime -nextlink $null 
}
else
{
$result= GetRunIds -Headers $headers -nextlink $nextlink 
}
$nextlink=$result.nextLink
#####Check If it is Bulk Cancel operation
if(($result.Value | Measure-Object).Count -ge 1)
{
if($Operation -eq 'BulkCancel')
{
if($i -eq 0)
{
Write-Host 'Confirm -Are you sure you want to perform this operation:'$Operation ',it cancels the running instances of the Logic App:'$LogicAppName 'as per the specified criteria..[Y] Yes,[N] No' -ForegroundColor White
$confirmation = Read-Host " Confirm [Y/N]" 
}
#Verify if there are any running instances
####Cancel runs retrieved running runs
if($confirmation -eq "Y")
{
if($i -eq 0)
{
$Filename=".\Cancelled_RunIds_$(Get-Date -Format 'yyyyMMdd.HHmmss').txt"
   New-Item $Filename
   Write-Host $Operation 'is in progress. Please wait till it gets completed' -ForegroundColor Green 
   $i=1
   }
   
foreach($Run in $result.Value)
{
CancelRun -headers $headers -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -LogicAppName $LogicAppName -RunId $Run.name -Filepath $Filename -RunIdStartTime $Run.properties.startTime
}
}
else
{
write-host 'You have disagreed to perform the operation:' $Operation -ForegroundColor Yellow
exit $true
}
}
####Executing Bulk Resbmit operation
else
{
if($i -eq 0)
{
Write-Host 'Confirm -Are you sure you want to perform this Operation' $Operation ',it resubmits runs as per specified Criteria..[Y] Yes,[N] No ' -ForegroundColor White
$confirmation = Read-Host " Confirm [Y/N]" 
}
#Verify if there are any running instances
if(($result.Value | Measure-Object).Count -ge 1)
{
# Resubmit runs retrieved failed run Ids
if($confirmation -eq "Y")
{
if($i -eq 0)
{
$Filename=".\Resubmitted_RunIds_$(Get-Date -Format 'yyyyMMdd.HHmmss').txt"
New-Item $FileName
Write-Host $Operation 'is in progress.Please wait till it gets completed' -ForegroundColor Green 
$i=1
}
foreach($Run in $result.Value)
{
$TriggerName= $Run.properties.trigger.name
ResubmitRun -headers $headers -SubscriptionId $SubscriptionId -ResourceGroupName $ResourceGroupName -LogicAppName $LogicAppName -RunId $Run.name -Filepath $Filename -RunIdStartTime $Run.properties.startTime
}

}
else
{
Write-Host 'You have disagreed to perform the operation' -ForegroundColor Yellow
Exit $true
}
}
else
{
Write-Host 'No Runs found for the specified operation:' $Operation ' and LogicApp Name:'$LogicAppName -ForegroundColor Yellow
}
}
}
else
{
if($i -eq 0)
{
Write-Host 'No Runs found for the specified operation:' $Operation ' and LogicApp Name:'$LogicAppName -ForegroundColor Yellow
}
}

if(($nextlink -eq $null) -and ($i -ne 0))
{
Write-Host 'The specified operation:'$Operation 'is succeeeded, you may verify it in the protal' -ForegroundColor Green
}
}While ($nextLink-ne $null)
}
catch{
Write-Host "An error occured while performing the specified Operaion $Operation. Error: $($PSItem.ToString())" -ForegroundColor Red
}

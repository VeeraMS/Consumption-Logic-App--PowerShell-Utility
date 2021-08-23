This PowerShell utility can be used to manage the Logic App runs such as cancelling or resubmitting the runs.

The below are the supported operations with this utility.

	1. BulkCancel - Cancel running instances
	2. BulkResubmitFailedRuns - Resubmits failed runs
	3. BulkResubmitCancelledRuns - Resubmits cancelled runs
	4. BulkResubmitSucceededRuns - Resubmits Succeeded runs

Steps to follow for executing the script:
	• Copy the PowerShell script attached here to desired folder
	• Ignore this step if your user has access to Logic App, you can login with your user creds to  perform bulk operations. 
	Set up Azure Service Principal - Contributor access on the Subscription. 
		 https://blog.jongallant.com/2017/11/azure-rest-apis-postman/
	• Open PowerShell with 'Run As administrator Privileges'
	• Run the below command to bypass the execution policy  and accept -Y
	      Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
	• Change the directory to the PowerShell script copied folder in first step.
	     cd  'PowerShellScriptFolderPath'
	• Execute the command to perform the different mentioned operations on Logic App
For user Sign-In option:
.\LogicAppUtility.ps1  -SubscriptionId 'Enter Subscription Id' -ResourceGroupName 'Enter resource Group Name' -LogicAppName 'Enter Logic App Name' -Operation 'BulkCancel' -StartTime '2020-11-02T16:33:00.000Z' -EndTime '2020-11-02T16:38:00.000Z’
For Azure AD SPN:
		.\LogicAppUtility.ps1 -ClientId 'Enter ClientId' -TenantId 'Enter TenantId' -Secret 'Enter Secret' -SubscriptionId 'Enter Subscription Id' -ResourceGroupName 'Enter resource Group Name' -LogicAppName 'Enter Logic App Name' -Operation 'BulkCancel' -StartTime '2020-11-02T16:33:00.000Z' -EndTime '2020-11-02T16:38:00.000Z’
		
	•  Validate the text file gets created in the same folder for list of run ids that are executed on specified operation.
	

Parameters definition:
S.No	Parameter Name	Mandatory	Comments
1	Client Id	No	The application /Client Id of your App Service Principal
2	Tenant Id	No	Tenant Id of Azure AD or App Service Principal 
3	Client Secret	No	Secret of your App Service Principal
4	Subscription Id	Yes	Subscription Id where Logic App present
5	Resource Group Name	Yes	Resource group Name in which Logic App is present
6	Logic App Name	Yes	Name of your Logic App
7	Operation	Yes	Allowed Values:
			        BulkCancel - Cancel running instances
			        BulkResubmitFailedRuns - Resubmits failed runs
			        BulkResubmitCancelledRuns - Resubmits cancelled runs
			        BulkResubmitSucceededRuns - Resubmits Succeeded runs
8	StartTime	No	If present all above operations will be performed on the runs started from the specified time.
			The Timestamp must be in UTC. 
			Ex: 2020-11-02T16:33:00.000Z
9	EndTime	No	You can include the EndTime along with StartTime if you want to perform above operations between specific timestamps.
			Note:
			It is invalid without StartTime. 


Script:

\\viki.fareast.corp.microsoft.com\BTSTeamShare\IndiaIntegrationTeam-TechTriages\2020-11-04-LA-PowerShell Utility
			

Note:
	• Not recommended to run directly on the Production environment
	• It is tested with limited test cases and volume of runs, Validate in test environments and then perform in Production
![image](https://user-images.githubusercontent.com/82495659/130430849-928f7d79-a310-4489-bcc1-b3da7b004b17.png)

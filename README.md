This PowerShell utility helps you to perform bulk operations on the Consumption Logic App runs. And the below are the supported operations with this utility.

	1. BulkCancel - Cancel running instances
	2. BulkResubmitFailedRuns - Resubmits failed runs
	3. BulkResubmitCancelledRuns - Resubmits cancelled runs
	4. BulkResubmitSucceededRuns - Resubmits Succeeded runs

**Steps to follow for executing the script:**

	Copy the PowerShell script desired folder

Set up Azure Service Principal - Contributor access on the Subscription. https://blog.jongallant.com/2017/11/azure-rest-apis-postman/

Open PowerShell with 'Run As administrator Privileges'

Run the below command to bypass the execution policy and accept -Y

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Change the directory to the PowerShell script folder where its available.

cd  'PowerShellScriptFolderPath'
Execute the one of the command below to perform the specified bulk operation on Standard Logic App workflow
	
	   To Log-in with user credentials:
	   
	     .\LogicAppUtility.ps1  -SubscriptionId 'Enter Subscription Id' -ResourceGroupName 'Enter resource Group Name' -LogicAppName 'Enter Logic App Name' -Operation                       'BulkCancel'           -StartTime '2020-11-02T16:33:00.000Z' -EndTime '2020-11-02T16:38:00.000Z’

	   To authenticate with user credentials:
	   
	     .\LogicAppUtility.ps1 -ClientId 'Enter ClientId' -TenantId Enter TenantId' -Secret 'Enter Secret' -SubscriptionId 'Enter Subscription Id' -ResourceGroupName 'Enter                  resource Group Name' -LogicAppName 'Enter Logic App Name' -Operation '*BulkCancel' -StartTime '2020-11-02T16:33:00.000Z' -EndTime '2020-11-02T16:38:00.000Z’
		
		
	7  Validate the text file gets created in the same folder for list of run ids that are executed on specified operation.
	

**Parameters definition:** 

![image](https://user-images.githubusercontent.com/82495659/130433993-aa08f0d1-521c-4053-8979-97cd098f03f3.png)

**Note:**

	• Not recommended to run directly on the Production environment
	
	• It is tested with limited test cases and volume of runs, Validate in test environments and then perform in Production


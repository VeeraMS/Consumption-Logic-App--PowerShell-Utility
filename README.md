# Consumption-Logic-App--PowerShell-Utility

This PowerShell utility helps you to perform bulk operations on the Consumption Logic App runs. And below are the supported operations with this utility.

1. BulkCancel - Cancel running instances
2. BulkResubmitFailedRuns - Resubmits failed runs
3. BulkResubmitCancelledRuns - Resubmits cancelled runs
4. BulkResubmitSucceededRuns - Resubmits Succeeded runs

**Steps to follow for executing the script:**

1. Copy the PowerShell script to the desired folder

2. Ignore this step if your using user creds to login. If not, proceed with creating App registration either from portal or using CLI command as in below blog.

	Set up Azure Service Principal - Contributor access on the Subscription. https://blog.jongallant.com/2017/11/azure-rest-apis-postman/

3. Open PowerShell with 'Run As administrator Privileges'

4. Run the below command to bypass the execution policy and accept -Y

		Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
	
5. Change the directory to the PowerShell script folder where its available.

		cd  'PowerShellScriptFolderPath'
6. Execute one of the below commands to perform the specified bulk operation on Conusmption Logic App.

 To Log-in with user credentials:
	   
	.\LogicAppUtility.ps1  -SubscriptionId 'Enter Subscription Id' -ResourceGroupName 'Enter resource Group Name' -LogicAppName 'Enter Logic App Name' -Operation 'BulkCancel' -StartTime '2020-11-02T16:33:00.000Z' -EndTime '2020-11-02T16:38:00.000Z’

To authenticate with user credentials:
	   
	.\LogicAppUtility.ps1 -ClientId 'Enter ClientId' -TenantId Enter TenantId' -Secret 'Enter Secret' -SubscriptionId 'Enter Subscription Id' -ResourceGroupName 'Enter                  resource Group Name' -LogicAppName 'Enter Logic App Name' -Operation '*BulkCancel' -StartTime '2020-11-02T16:33:00.000Z' -EndTime '2020-11-02T16:38:00.000Z’
	     
7.  Log file gets generated in the script folder with the Run ids and their Start time, you may use these to cross verify the operation in the portal.
	

**Parameters definition:** 

![image](https://user-images.githubusercontent.com/82495659/130433993-aa08f0d1-521c-4053-8979-97cd098f03f3.png)

**Note:**

1. Not recommended to run directly on the Production environment
	
2. It is tested with limited test cases and volume of runs, validate this in test environment prior to execute in Production.


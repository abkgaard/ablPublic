using './main.bicep'

param name = 'abllabdevstor34'
param containerNames = [
  'storageTransfer'
]
//Group object IDs that are supposed to have Storage Blob Data Contributor permissions
param dataContributorGroupsId = [
  '2052280b-0bd7-4af9-a163-e83950d0f903'
]

//Diagnostic logs destination
param logAnalyticsWorkspaceId = '/subscriptions/7a86d903-0585-40e1-8af9-92a5efc19c1c/resourcegroups/coreloganalytics-prd/providers/microsoft.operationalinsights/workspaces/coreloganalytics-prd'

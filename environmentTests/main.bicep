param location string = resourceGroup().location

@maxLength(21)
param name string

param dataContributorGroupsId array
param containerNames array
param logAnalyticsWorkspaceId string

var strgName = '${toLower(name)}${take(uniqueString((resourceGroup().id)), 3)}'
var storageBlobDataContributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions','ba92f5b4-2d11-453d-a403-e96b0029c9fe')
var readerRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions','acdd72a7-3385-48ef-bd42-f606fba81ae7')

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: strgName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    publicNetworkAccess: 'Enabled'
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  parent: storageAccount
  name: 'default'
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = [for containerName in containerNames : {
  parent: blobService
  name: toLower(containerName)
}]

resource auditSetting 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: blobService
  name: 'diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
      {
        categoryGroup: 'audit'
        enabled: true
      }
    ]
  }
}

resource roleAssignmentDataContributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for member in dataContributorGroupsId: {
  name: guid('${storageAccount.id}-${member}-${storageBlobDataContributorRoleId}')
  scope: storageAccount
  properties: {
    roleDefinitionId: storageBlobDataContributorRoleId
    principalId: member
    principalType: 'Group'
  }
}]

resource roleAssignmentReader 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for member in dataContributorGroupsId: {
  name: guid('${storageAccount.id}-${member}-${readerRoleId}')
  scope: storageAccount
  properties: {
    roleDefinitionId: readerRoleId
    principalId: member
    principalType: 'Group'
  }
}]

/*

Template: storageAccount.bicep

*/

// Standard Parameters.
param strName string
param strFileShareName string
param strSku string
param strKind string
param strAccessTier string
param strSupportHttpsTrafficOnly bool
param strMinimumTlsVersion string
param azLoc string

// Tag Parameters.
param strTagName string
param strTagEnvName string
param strTagDeployedBy string

// Storage Account Template.
resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: strName
  location: azLoc
  kind: strKind
  sku: {
    name: strSku
  }
  properties: {
    accessTier: strAccessTier
    supportsHttpsTrafficOnly: strSupportHttpsTrafficOnly
    minimumTlsVersion: strMinimumTlsVersion
  }
  tags: {
    Name: strTagName
    Environment: strTagEnvName
    DeployedBy: strTagDeployedBy
  }
}

// Storage Account File Share.
resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2019-06-01' = {
  name: '${storageAccount.name}/default/${strFileShareName}'
  properties: {
    accessTier: 'Hot'
  }
  dependsOn: [
    storageAccount
  ]
}

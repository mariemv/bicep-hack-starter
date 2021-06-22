/*

Template: keyVault.bicep

*/

// Standard Parameters.
param kvName string
param azLoc string
param tenantId string
param kvAccessPolicies array
param kvIpRules array
param kvVirtualNetworkRules array

// Tag Parameters.
param kvTagName string
param kvTagEnvName string
param kvTagDeployedBy string

// Keyvault Template 
resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: kvName
  location: azLoc
  properties: {
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    accessPolicies: kvAccessPolicies
    sku: {
      name: 'standard'
      family: 'A'
    }
    tenantId: tenantId
    enableSoftDelete: true
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      ipRules: kvIpRules
      virtualNetworkRules: kvVirtualNetworkRules
    }
  }
  tags: {
    Name: kvTagName
    Environment: kvTagEnvName
    DeployedBy: kvTagDeployedBy
  }
}

/*

Template: aksVnet.bicep

*/

// Standard Parameters.
param vnetName string
param vnetaddressPrefix string
param subnetaddressPrefix string
param subnetName string
param azLoc string
param privateEndpointNetworkPolicy string = 'Disabled'

// Tag Parameters.
param vnetTagName string
param vnetTagEnvName string
param vnetTagDeployedBy string

// Deploy AKS VNet and Subnet.
resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetName
  location: azLoc
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetaddressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetaddressPrefix
          serviceEndpoints: [
            {
              service: 'Microsoft.Keyvault'
            }
          ]
          privateEndpointNetworkPolicies: privateEndpointNetworkPolicy
        }
      }
    ]
  }
  tags: {
    Name: vnetTagName
    Environment: vnetTagEnvName
    DeployedBy: vnetTagDeployedBy
  }
}

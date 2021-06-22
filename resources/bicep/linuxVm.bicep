/*

Template: virtualNetwork.bicep

*/

// Standard Parameters.

param azLoc string
param subnetId string
param nicName string
param vmName string
param vmDiskSize int
param imagePublisher string
param imageOffer string
param imageSku string
param imageVersion string
param adminUsername string
param vmSize string
param nsgName string
param sshRule string
param adminPublicKey string

// // Tag Parameters.
param nicTagName string
param nicTagEnvName string
param nicTagDeployedBy string
param vmTagName string
param vmTagEnvName string
param vmTagDeployedBy string

//NetworkSecurityGroupR Template
resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2020-06-01' = {
  name: nsgName
  location: azLoc
  properties: {
    securityRules: [
      {
        name: sshRule
        properties: {
          description: 'Locks inbound down to ssh default port 22.'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 123
          direction: 'Inbound'
        }
      }
    ]
  }
}

// 
resource publicIP 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: vmName
  location: azLoc
  sku: {
    name: 'Basic'
  }
  properties: {
    dnsSettings: {
      domainNameLabel: vmName
    }
    publicIPAllocationMethod: 'Dynamic'
  }
}
// Network Interface Template 
resource networkInterface 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: nicName
  location: azLoc
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: '${networkSecurityGroup.id}'
    }
  }
  tags: {
    Name: nicTagName
    Environment: nicTagEnvName
    DeployedBy: nicTagDeployedBy
  }
}

// Virtual Machine Template.
resource virtualMachine 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: vmName
  location: azLoc
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: adminPublicKey
            }
          ]
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          properties: {
            primary: true
          }
          id: networkInterface.id
        }
      ]
    }
    storageProfile: {
      imageReference: {
        publisher: imagePublisher
        offer: imageOffer
        sku: imageSku
        version: imageVersion
      }
      osDisk: {
        createOption: 'FromImage'
        diskSizeGB: vmDiskSize
      }
    }
  }
  tags: {
    Name: vmTagName
    Environment: vmTagEnvName
    DeployedBy: vmTagDeployedBy
  }
}

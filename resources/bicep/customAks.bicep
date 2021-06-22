/*

Template: customAks.bicep

*/

// Standard Parameters.
param aksClusterName string
param aksClusterDnsPrefix string
param aksSubnetId string
param aksClusterAdminUsername string
param aksClusterSshPublicKey string
param nodePoolCount int
param nodePoolMaxCount int
param nodePoolMinCount int
param nodeResourceGroupName string
param nodePoolEnableAutoScaling bool
param aadEnabled bool
param aksClusterEnablePrivateCluster bool
param aadProfileManaged bool
param aadProfileEnableAzureRBAC bool
param azLoc string

// Additional AKS Parameters that ar staticly set.
param aadProfileTenantId string = subscription().tenantId
param aksClusterNetworkPlugin string = 'azure'
param aksClusterNetworkPolicy string = 'azure'
param aksClusterPodCidr string = '10.244.0.0/16'
param aksClusterServiceCidr string = '10.2.0.0/16'
param aksClusterDnsServiceIP string = '10.2.0.10'
param aksClusterDockerBridgeCidr string = '172.17.0.1/16'
param aksClusterLoadBalancerSku string = 'standard'
param aksClusterKubernetesVersion string = '1.20.5'
param nodePoolName string = 'nodepool1'
param nodePoolVmSize string = 'Standard_DS3_v2'
param nodePoolOsType string = 'Linux'
param nodePoolOsDiskSizeGB int = 128
param nodePoolMaxPods int = 30
param nodePoolScaleSetPriority string = 'Regular'
param nodePoolNodeLabels object = {}
param nodePoolNodeTaints array = []
param nodePoolMode string = 'System'
param nodePoolType string = 'VirtualMachineScaleSets'
param nodePoolAvailabilityZones array = []
param aadProfileAdminGroupObjectIDs array = []

// Tag Parameters.
param aksTagName string
param aksTagEnvName string
param aksTagDeployedBy string

var aadProfileConfiguration = {
  managed: aadProfileManaged
  enableAzureRBAC: aadProfileEnableAzureRBAC
  adminGroupObjectIDs: aadProfileAdminGroupObjectIDs
  tenantID: aadProfileTenantId
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-02-01' = {
  name: aksClusterName
  location: azLoc
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: aksClusterKubernetesVersion
    dnsPrefix: aksClusterDnsPrefix
    nodeResourceGroup: nodeResourceGroupName

    agentPoolProfiles: [
      {
        name: toLower(nodePoolName)
        count: nodePoolCount
        vmSize: nodePoolVmSize
        osDiskSizeGB: nodePoolOsDiskSizeGB
        vnetSubnetID: aksSubnetId
        maxPods: nodePoolMaxPods
        osType: nodePoolOsType
        maxCount: nodePoolMaxCount
        minCount: nodePoolMinCount
        scaleSetPriority: nodePoolScaleSetPriority
        enableAutoScaling: nodePoolEnableAutoScaling
        mode: nodePoolMode
        type: nodePoolType
        availabilityZones: any(empty(nodePoolAvailabilityZones) ? null : nodePoolAvailabilityZones)
        nodeLabels: nodePoolNodeLabels
        nodeTaints: nodePoolNodeTaints
      }
    ]
    linuxProfile: {
      adminUsername: aksClusterAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: aksClusterSshPublicKey
          }
        ]
      }
    }
    enableRBAC: true
    networkProfile: {
      networkPlugin: aksClusterNetworkPlugin
      networkPolicy: aksClusterNetworkPolicy
      podCidr: aksClusterPodCidr
      serviceCidr: aksClusterServiceCidr
      dnsServiceIP: aksClusterDnsServiceIP
      dockerBridgeCidr: aksClusterDockerBridgeCidr
      loadBalancerSku: aksClusterLoadBalancerSku
    }
    aadProfile: (aadEnabled ? aadProfileConfiguration : json('null'))
    apiServerAccessProfile: {
      enablePrivateCluster: aksClusterEnablePrivateCluster
    }
  }
  tags: {
    Name: aksTagName
    Environment: aksTagEnvName
    DeployedBy: aksTagDeployedBy
  }
}

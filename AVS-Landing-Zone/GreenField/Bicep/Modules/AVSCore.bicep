targetScope = 'subscription'

param Location string
param Prefix string
param PrivateCloudAddressSpace string
param ManagementClusterSize int

resource PrivateCloudResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${Prefix}-PrivateCloud'
  location: Location
}

module PrivateCloud 'AVSCore/PrivateCloud.bicep' = {
  scope: PrivateCloudResourceGroup
  name: '${deployment().name}-PrivateCloud'
  params: {
    Prefix: Prefix
    Location: Location
    NetworkBlock: PrivateCloudAddressSpace
    ManagementClusterSize: ManagementClusterSize
  }
}

output PrivateCloudName string = PrivateCloud.outputs.PrivateCloudName
output PrivateCloudResourceGroupName string = PrivateCloudResourceGroup.name
output PrivateCloudResourceId string = PrivateCloud.outputs.PrivateCloudResourceId

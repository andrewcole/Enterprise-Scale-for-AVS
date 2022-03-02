targetScope = 'subscription'
param VNetResourceGroup string
param VNetName string
param MigrationSubnet string

module Subnet 'Migration/MigrationSubnet.bicep' = {
  name: 'Migration-Subnet'
  scope: resourceGroup(VNetResourceGroup)
  params:{
    VNetName: VNetName
    MigrationSubnet: MigrationSubnet
  }
}

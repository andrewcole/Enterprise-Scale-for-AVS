targetScope = 'subscription'

param Location string
param Prefix string
param VNetGatewaySubnet string
param VNetName string
param NetworkResourceGroup string

module Network 'Networking/VNetWithGW.bicep' = {
  scope: resourceGroup(NetworkResourceGroup)
  name: '${deployment().name}-Network'
  params: {
    Prefix: Prefix
    Location: Location
    VNetGatewaySubnet: VNetGatewaySubnet
    VNetName: VNetName
  }
}

output GatewayName string = Network.outputs.GatewayName
output VNetName string = Network.outputs.VNetName
output VNetResourceId string = Network.outputs.VNetResourceId

param Location string = resourceGroup().location
param Prefix string
param VNetGatewaySubnet string
param GatewaySku string = 'Standard'
param VNetName string

var GatewayName = '${Prefix}-GW'

resource VNet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: VNetName
}

resource GatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: 'GatewaySubnet'
  parent: VNet
  properties: {
    addressPrefix: VNetGatewaySubnet
  }
}

resource GatewayPIP 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: '${GatewayName}-PIP'
  location: Location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
  sku: {
    name: 'Basic'
    tier: 'Regional'
  }
}
resource Gateway 'Microsoft.Network/virtualNetworkGateways@2021-02-01' = {
  name: GatewayName
  location: Location
  properties: {
    gatewayType: 'ExpressRoute'
    sku: {
      name: GatewaySku
      tier: GatewaySku
    }
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: GatewaySubnet.id
          }
          publicIPAddress: {
            id: GatewayPIP.id
          }
        }
      }
    ]
  }
}

output VNetName string = VNet.name
output GatewayName string = Gateway.name
output VNetResourceId string = VNet.id

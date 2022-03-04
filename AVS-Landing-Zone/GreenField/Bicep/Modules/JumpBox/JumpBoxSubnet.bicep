param VNetName string
param Prefix string
param JumpboxSubnet string
param Location string

var Name = '${Prefix}-jumpbox'

resource VNet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: VNetName
}

resource NetworkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: Name
  location: Location
  properties: {
    securityRules: [
      {
        name: 'AllowRDP'
        properties: {
          description: 'This will allow RDP traffic into the subnet'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: [
            '3389'
          ]
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }

    ]
  }
}

resource Subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: 'JumpBox'
  parent: VNet
  properties: {
    addressPrefix: JumpboxSubnet
    networkSecurityGroup: {
      id: NetworkSecurityGroup.id
    }
  }
}

output JumpBoxSubnetId string = Subnet.id

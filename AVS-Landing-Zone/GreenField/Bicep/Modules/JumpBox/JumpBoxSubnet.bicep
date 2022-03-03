param VNetName string
param JumpboxSubnet string
param Location string

resource VNet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: VNetName
}

resource NetworkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: 'name'
  location: Location
  properties: {
    securityRules: [
      {
        name: 'AllowRDP'
        properties: {
          description: 'This will allow RDP traffic into the subnet'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowSMB'
        properties: {
          description: 'This will allow SMB traffic into the subnet'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '139,445'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 102
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource JumpBox 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: 'JumpBox'
  parent: VNet
  properties: {
    addressPrefix: JumpboxSubnet
    networkSecurityGroup: {
      id: NetworkSecurityGroup.id
    }
  }
}

output JumpBoxSubnetId string = JumpBox.id

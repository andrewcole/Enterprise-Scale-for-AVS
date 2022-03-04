param VNetName string
param JumpboxSubnet string
param Location string

resource VNet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: VNetName
}

resource JumpBox 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: 'JumpBox'
  parent: VNet
  properties: {
    addressPrefix: JumpboxSubnet
    networkSecurityGroup: {
      id: 'name'
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
        ]
      }
    }
  }

}


output JumpBoxSubnetId string = JumpBox.id

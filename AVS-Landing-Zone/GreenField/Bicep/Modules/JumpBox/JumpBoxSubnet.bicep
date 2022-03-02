param VNetName string
param JumpboxSubnet string

resource VNet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: VNetName
}

resource JumpBox 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: 'JumpBox'
  parent: VNet
  properties: {
    addressPrefix: JumpboxSubnet
  }
}

output JumpBoxSubnetId string = JumpBox.id

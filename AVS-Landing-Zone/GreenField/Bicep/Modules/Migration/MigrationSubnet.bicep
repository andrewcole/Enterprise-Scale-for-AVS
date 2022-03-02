param VNetName string
param MigrationSubnet string

resource VNet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: VNetName
}

resource Migration 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = {
  name: 'Migration'
  parent: VNet
  properties: {
    addressPrefix: MigrationSubnet
  }
}

output MigrationSubnetId string = Migration.id

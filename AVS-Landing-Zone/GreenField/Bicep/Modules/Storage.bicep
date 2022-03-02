targetScope = 'subscription'
param ResourceGroup string
param Name string
param Location string

module StorageAccount 'Storage/StorageAccount.bicep' = {
  name: 'Storage-Account'
  scope: resourceGroup(ResourceGroup)
  params:{
    Name: Name
    Location: Location
  }
}

param Name string
param Location string

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: Name
  location: Location
  kind: 'StorageV2'
  sku: {
    name: 'Premium_LRS'
  }
}

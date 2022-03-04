param Prefix string
param SubnetId string
param Location string = resourceGroup().location
param Username string
@secure()
param Password string
param VMSize string
param OSVersion string = '2019-Datacenter-smalldisk'
param PublicIP bool

var Name = '${Prefix}-jumpbox'
var Hostname = 'avsjumpbox'

resource PublicIPAddress 'Microsoft.Network/publicIPAddresses@2019-11-01' = if (PublicIP) {
  name: Name
  location: Location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}


resource Nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: Name
  location: Location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          publicIPAddress: PublicIP ? {
            id: PublicIPAddress.id
          } : null
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: SubnetId
          }
        }
      }
    ]
  }
}

resource VM 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: Name
  location: Location
  properties: {
    hardwareProfile: {
      vmSize: VMSize
    }
    osProfile: {
      computerName: Hostname
      adminUsername: Username
      adminPassword: Password
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: Nic.id
        }
      ]
    }
  }
}

output JumpboxResourceId string = VM.id

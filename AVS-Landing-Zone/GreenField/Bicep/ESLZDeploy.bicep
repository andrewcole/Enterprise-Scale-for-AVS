targetScope = 'subscription'

@description('The region the Enterpise Landing Zone and associated resources will be deployed to')
param ELZLocation string = 'AustraliaCentral'

@description('The region the AVS Private Cloud & associated resources will be deployed to')
param AVSLocation string = 'AustraliaEast'

@description('The prefix to use on resources inside this template')
@minLength(1)
@maxLength(20)
param Prefix string = 'SBB'

@description('The address space used for the AVS Private Cloud management networks. Must be a non-overlapping /22')
param PrivateCloudAddressSpace string = '10.0.0.0/22'

@description('Specify the name of the VNet')
param VNetName string

@description('Specify the name of the Network Resource Group')
param NetworkResourceGroup string

@description('The subnet CIDR used for the Gateway Subnet. Must be a /24 or greater within the VNetAddressSpace')
param VNetGatewaySubnet string = '10.1.1.128/26'

@description('Email addresses to be added to the alerting action group. Use the format ["name1@domain.com","name2@domain.com"].')
param AlertEmails array = [
  'francois.legrange@microsoft.com'
]
@description('Should a Jumpbox deployed to access the Private Cloud')
param DeployJumpbox bool = true
@description('Should a Migration subnet be deployed')
param DeployMigrationSubnet bool = true

@description('Username for the Jumpbox VM')
param JumpboxUsername string = 'avsjump'
@secure()
@description('Password for the Jumpbox VM, can be changed later')
param JumpboxPassword string
@description('The subnet CIDR used for the Jumpbox VM Subnet. Must be a /26 or greater within the VNetAddressSpace')
param JumpboxSubnet string = '10.1.1.0/26'
@description('The sku to use for the Jumpbox VM, must have quota for this within the target region')
param JumpboxSku string = 'Standard_D2s_v3'

@description('Should some storage be deployed to the ELZ')
param DeployStorage bool = true

@description('Specify the name of the Storage Account')
param StorageName string

@description('The subnet CIDR used for the Migration Subnet. Must be a /26 or greater within the VNetAddressSpace')
param MigrationSubnet string = '10.1.1.64/26'

@description('Should HCX be deployed as part of the deployment')
param DeployHCX bool = true
@description('Should SRM be deployed as part of the deployment')
param DeploySRM bool = false
@description('License key to be used if SRM is deployed')
param SRMLicenseKey string = ''
@minValue(3)
@maxValue(12)
@description('Number of vSphere ESXi hosts to be created')
param ManagementClusterSize int = 3

@minValue(1)
@maxValue(10)
@description('Number of vSphere Replication Servers to be created if SRM is deployed')
param VRServerCount int = 1

var deploymentPrefix = 'AVS-${uniqueString(deployment().name)}'

module AVSCore 'Modules/AVSCore.bicep' = {
  name: '${deploymentPrefix}-AVS'
  params: {
    Prefix: Prefix
    Location: AVSLocation
    PrivateCloudAddressSpace: PrivateCloudAddressSpace
    ManagementClusterSize: ManagementClusterSize
  }
}

module Networking 'Modules/Networking.bicep' = {
  name: '${deploymentPrefix}-Network'
  params: {
    Prefix: Prefix
    Location: ELZLocation
    VNetGatewaySubnet: VNetGatewaySubnet
    VNetName: VNetName
    NetworkResourceGroup: NetworkResourceGroup
  }
}

module VNetConnection 'Modules/VNetConnection.bicep' = {
  name: '${deploymentPrefix}-VNet'
  params: {
    GatewayName: Networking.outputs.GatewayName
    NetworkResourceGroup: NetworkResourceGroup
    VNetPrefix: Prefix
    PrivateCloudName: AVSCore.outputs.PrivateCloudName
    PrivateCloudResourceGroup: AVSCore.outputs.PrivateCloudResourceGroupName
    Location: ELZLocation
  }
}

module Addons 'Modules/AVSAddons.bicep' = {
  name: '${deploymentPrefix}-AVSAddons'
  params: {
    PrivateCloudName: AVSCore.outputs.PrivateCloudName
    PrivateCloudResourceGroup: AVSCore.outputs.PrivateCloudResourceGroupName
    DeployHCX: DeployHCX
    DeploySRM: DeploySRM
    SRMLicenseKey: SRMLicenseKey
    VRServerCount: VRServerCount
  }
}

module Jumpbox 'Modules/JumpBox.bicep' = if (DeployJumpbox) {
  name: '${deploymentPrefix}-Jumpbox'
  params: {
    Prefix: Prefix
    Location: ELZLocation
    Username: JumpboxUsername
    Password: JumpboxPassword
    VNetName: VNetName
    VNetResourceGroup: NetworkResourceGroup
    JumpboxSubnet: JumpboxSubnet
    JumpboxSku: JumpboxSku
  }
}

module Migration 'Modules/Migration.bicep' = if (DeployMigrationSubnet) {
  name: '${deploymentPrefix}-Migration'
  params: {
    VNetName: VNetName
    VNetResourceGroup: NetworkResourceGroup
    MigrationSubnet: MigrationSubnet
  }
}

module Storage 'Modules/Storage.bicep' = if (DeployStorage) {
  name: '${deploymentPrefix}-Storage'
  params: {
    Name: '${StorageName}${uniqueString(deployment().name)}'
    ResourceGroup: NetworkResourceGroup
    Location: ELZLocation
  }
}

module OperationalMonitoring 'Modules/Monitoring.bicep' = {
  name: '${deploymentPrefix}-Monitoring'
  params: {
    AlertEmails: AlertEmails
    Prefix: Prefix
    PrimaryLocation: AVSLocation
    PrimaryPrivateCloudName: AVSCore.outputs.PrivateCloudName
    PrimaryPrivateCloudResourceId: AVSCore.outputs.PrivateCloudResourceId
    JumpboxResourceId: DeployJumpbox ? Jumpbox.outputs.JumpboxResourceId : ''
    VNetResourceId: Networking.outputs.VNetResourceId
    ExRConnectionResourceId: VNetConnection.outputs.ExRConnectionResourceId
  }
}


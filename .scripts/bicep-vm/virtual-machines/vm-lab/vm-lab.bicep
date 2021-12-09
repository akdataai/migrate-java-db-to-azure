param namePrefix string
param RdpSubnetId string
param username string
param password string

var vmName = namePrefix

module vm_pgsql '../general/vm-small/vm-small.bicep' = {
  name: vmName
  params: {
    namePrefix: vmName
    location: resourceGroup().location
    subnetId: RdpSubnetId
    OSPublisher: 'MicrosoftVisualStudio'
    OSOffer: 'visualstudio2019latest'
    Sku: 'vs-2019-comm-latest-ws2019' 
    Version: 'latest'
    osDiskType: 'Standard_LRS'
    vmSize: 'Standard_D4s_v3'
    username: username
    password: password
    privateIPAddress:  '10.1.0.4'
    customData: ''
  }
}

output vmId string = vm_pgsql.outputs.id

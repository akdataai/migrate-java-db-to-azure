param namePrefix string
param PgSubnetId string
param username string
param password string

var vmName = '${namePrefix}-pgsql'

module vm_pgsql '../general/vm-small/vm-small.bicep' = {
  name: vmName
  params: {
    namePrefix: vmName
    location: resourceGroup().location
    subnetId: PgSubnetId
    OSPublisher: 'OpenLogic'
    OSOffer: 'CentOS'
    Sku: '8_4-gen2'
    Version: 'latest'
    osDiskType: 'Standard_LRS'
    vmSize: 'Standard_D4s_v3'
    username: username
    password: password    
    privateIPAddress:  '10.2.0.4'
  }
}

output vmId string = vm_pgsql.outputs.id

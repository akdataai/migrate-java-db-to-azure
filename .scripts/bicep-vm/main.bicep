targetScope = 'resourceGroup'

param vmUsername string
param vmPassword string
param resourceGroupName string
param namePrefix string
param vnetName string = '${namePrefix}-vnet'

module vnet_generic './vnets/vnet-generic.bicep' = {
  name: 'vnet'
  scope: resourceGroup(resourceGroupName)
  params: {
    vnetName: vnetName
  }
}


module vm_pgsql './virtual-machines/vm-postgresql/vm-postgresql.bicep' = {
  name: 'vm-pgsql'
  scope: resourceGroup(resourceGroupName)
  params: {
    namePrefix: '${namePrefix}-vm'
    PgSubnetId: vnet_generic.outputs.PgSubnetId
    username: vmUsername
    password: vmPassword
  }
}

output PgVmName string = vm_pgsql.name

module vm_lab './virtual-machines/vm-lab/vm-lab.bicep' = {
  name: 'vm-lab'
  scope: resourceGroup(resourceGroupName)
  params: {
    namePrefix: '${namePrefix}-rdp'
    RdpSubnetId: vnet_generic.outputs.RdpSubnetId
    username: vmUsername
    password: vmPassword
  }
}
 
output LabVmName string = vm_lab.name

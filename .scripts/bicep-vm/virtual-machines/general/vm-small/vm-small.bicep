param namePrefix string
param location string = resourceGroup().location
param subnetId string
param Version string
param Sku string
param osDiskType string
param vmSize string
param username string
param password string
param OSPublisher string
param OSOffer string
param privateIPAddress string

var vmName = namePrefix

// Bring in the nic
module nic './vm-small-nic.bicep' = {
  name: '${vmName}-nic'
  params: {
    namePrefix: '${vmName}-nic'
    subnetId: subnetId
    privateIPAddress: privateIPAddress
  }
}

// Create the vm
resource vm_small 'Microsoft.Compute/virtualMachines@2019-07-01' = {
  name: vmName
  location: location
  zones: [
    '1'
  ]
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      imageReference: {
        publisher: OSPublisher
        offer: OSOffer
        sku: Sku
        version: Version
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: username
      adminPassword: password
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.outputs.nicId
        }
      ]
    }
  }
}

output id string = vm_small.id

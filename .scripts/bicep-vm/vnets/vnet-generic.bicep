param location string = resourceGroup().location
param vnetName string

var PgSubnetName = 'PgSubnet'
var RdpSubnetName = 'RdpSubnet'

resource vnet_generic 'Microsoft.Network/virtualNetworks@2020-08-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: PgSubnetName
        properties: {
          addressPrefix: '10.0.1.0/24'
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: RdpSubnetName
        properties: {
          addressPrefix: '10.0.2.0/24'
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

output vnetId string = vnet_generic.id
output PgSubnetId string = '${vnet_generic.id}/subnets/${PgSubnetName}'
output RdpSubnetId string = '${vnet_generic.id}/subnets/${RdpSubnetName}'
output PgSubnetName string = PgSubnetName
output RdpSubnetName string = RdpSubnetName


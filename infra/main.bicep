param location string = resourceGroup().location
param adminUsername string = 'azureuser'
@secure()
param adminPassword string
param vmSize string = 'Standard_B2s_v2'

var vnetName = 'vnet-lb-agw'
var backendSubnetName = 'backend-subnet'
var appgwSubnetName = 'appgw-subnet'
var backendPrefix = '10.20.1.0/24'
var appgwPrefix = '10.20.2.0/24'

resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.20.0.0/16']
    }
    subnets: [
      {
        name: backendSubnetName
        properties: {
          addressPrefix: backendPrefix
          defaultOutboundAccess: true
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
      {
        name: appgwSubnetName
        properties: {
          addressPrefix: appgwPrefix
        }
      }
    ]
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: 'nsg-backends'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-HTTP-From-LB'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'AzureLoadBalancer'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '80'
        }
      }
      {
        name: 'Allow-HTTP-From-AppGateway'
        properties: {
          priority: 110
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: backendPrefix
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '80'
        }
      }
      {
        name: 'Allow-AppGateway-Backend-Ports'
        properties: {
          priority: 120
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: appgwPrefix
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '8081-8082'
        }
      }
      {
        name: 'Allow-SSH-From-VNet-Only'
        properties: {
          priority: 200
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourceAddressPrefix: 'VirtualNetwork'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
    ]
  }
}

resource lbPip 'Microsoft.Network/publicIPAddresses@2024-07-01' = {
  name: 'pip-lb'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource agwPip 'Microsoft.Network/publicIPAddresses@2024-07-01' = {
  name: 'pip-agw'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource lb 'Microsoft.Network/loadBalancers@2024-07-01' = {
  name: 'lb-standard-demo'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'lb-frontend'
        properties: {
          publicIPAddress: {
            id: lbPip.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'lb-backend-pool'
      }
    ]
    probes: [
      {
        name: 'lb-http-probe'
        properties: {
          protocol: 'Http'
          port: 80
          requestPath: '/health'
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
    loadBalancingRules: [
      {
        name: 'lb-http-rule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', 'lb-standard-demo', 'lb-frontend')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', 'lb-standard-demo', 'lb-backend-pool')
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', 'lb-standard-demo', 'lb-http-probe')
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          enableFloatingIP: false
          idleTimeoutInMinutes: 15
          enableTcpReset: true
        }
      }
    ]
  }
}

resource nic1 'Microsoft.Network/networkInterfaces@2024-07-01' = {
  name: 'nic-backend-01'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.20.1.10'
          subnet: { id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, backendSubnetName) }
          loadBalancerBackendAddressPools: [
            { id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lb.name, 'lb-backend-pool') }
          ]
        }
      }
    ]
  }
}

resource nic2 'Microsoft.Network/networkInterfaces@2024-07-01' = {
  name: 'nic-backend-02'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: '10.20.1.11'
          subnet: { id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, backendSubnetName) }
          loadBalancerBackendAddressPools: [
            { id: resourceId('Microsoft.Network/loadBalancers/backendAddressPools', lb.name, 'lb-backend-pool') }
          ]
        }
      }
    ]
  }
}

var cloudInit = base64(loadTextContent('../backend/cloud-init.sh'))

resource vm1 'Microsoft.Compute/virtualMachines@2024-11-01' = {
  name: 'vm-backend-01'
  location: location
  properties: {
    hardwareProfile: { vmSize: vmSize }
    osProfile: {
      computerName: 'backend01'
      adminUsername: adminUsername
      adminPassword: adminPassword
      customData: cloudInit
      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'ubuntu-24_04-lts'
        sku: 'server'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: { storageAccountType: 'Standard_LRS' }
      }
    }
    networkProfile: {
      networkInterfaces: [
        { id: nic1.id }
      ]
    }
  }
}

resource vm2 'Microsoft.Compute/virtualMachines@2024-11-01' = {
  name: 'vm-backend-02'
  location: location
  properties: {
    hardwareProfile: { vmSize: vmSize }
    osProfile: {
      computerName: 'backend02'
      adminUsername: adminUsername
      adminPassword: adminPassword
      customData: cloudInit
      linuxConfiguration: {
        disablePasswordAuthentication: false
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'ubuntu-24_04-lts'
        sku: 'server'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: { storageAccountType: 'Standard_LRS' }
      }
    }
    networkProfile: {
      networkInterfaces: [
        { id: nic2.id }
      ]
    }
  }
}

resource appgw 'Microsoft.Network/applicationGateways@2024-07-01' = {
  name: 'agw-standard-v2-demo'
  location: location
  properties: {
    sku: {
      name: 'Standard_v2'
      tier: 'Standard_v2'
    }
    enableHttp2: true
    autoscaleConfiguration: {
      minCapacity: 1
      maxCapacity: 2
    }
    gatewayIPConfigurations: [
      {
        name: 'agw-ipconfig'
        properties: {
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', vnetName, appgwSubnetName)
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'agw-frontend'
        properties: {
          publicIPAddress: {
            id: agwPip.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port-80'
        properties: { port: 80 }
      }
    ]
    backendAddressPools: [
      {
        name: 'products-pool'
        properties: {
          backendAddresses: [
            { ipAddress: '10.20.1.10' }
            { ipAddress: '10.20.1.11' }
          ]
        }
      }
      {
        name: 'orders-pool'
        properties: {
          backendAddresses: [
            { ipAddress: '10.20.1.10' }
            { ipAddress: '10.20.1.11' }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [
      {
        name: 'products-settings'
        properties: {
          port: 8081
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
          probeEnabled: true
          probe: { id: resourceId('Microsoft.Network/applicationGateways/probes', 'agw-standard-v2-demo', 'products-probe') }
        }
      }
      {
        name: 'orders-settings'
        properties: {
          port: 8082
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          requestTimeout: 30
          probeEnabled: true
          probe: { id: resourceId('Microsoft.Network/applicationGateways/probes', 'agw-standard-v2-demo', 'orders-probe') }
        }
      }
    ]
    probes: [
      {
        name: 'products-probe'
        properties: {
          protocol: 'Http'
          path: '/health'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          host: '10.20.1.10'
          port: 8081
        }
      }
      {
        name: 'orders-probe'
        properties: {
          protocol: 'Http'
          path: '/health'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          host: '10.20.1.10'
          port: 8082
        }
      }
    ]
    httpListeners: [
      {
        name: 'http-listener'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', 'agw-standard-v2-demo', 'agw-frontend')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', 'agw-standard-v2-demo', 'port-80')
          }
          protocol: 'Http'
        }
      }
    ]
    urlPathMaps: [
      {
        name: 'path-map'
        properties: {
          defaultBackendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', 'agw-standard-v2-demo', 'products-pool')
          }
          defaultBackendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', 'agw-standard-v2-demo', 'products-settings')
          }
          pathRules: [
            {
              name: 'products-rule'
              properties: {
                paths: ['/products/*', '/products']
                backendAddressPool: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', 'agw-standard-v2-demo', 'products-pool')
                }
                backendHttpSettings: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', 'agw-standard-v2-demo', 'products-settings')
                }
              }
            }
            {
              name: 'orders-rule'
              properties: {
                paths: ['/orders/*', '/orders']
                backendAddressPool: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', 'agw-standard-v2-demo', 'orders-pool')
                }
                backendHttpSettings: {
                  id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', 'agw-standard-v2-demo', 'orders-settings')
                }
              }
            }
          ]
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'path-rule'
        properties: {
          ruleType: 'PathBasedRouting'
          priority: 100
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', 'agw-standard-v2-demo', 'http-listener')
          }
          urlPathMap: {
            id: resourceId('Microsoft.Network/applicationGateways/urlPathMaps', 'agw-standard-v2-demo', 'path-map')
          }
        }
      }
    ]
  }
}

output loadBalancerPublicIp string = lbPip.properties.ipAddress
output applicationGatewayPublicIp string = agwPip.properties.ipAddress
output loadBalancerUrl string = 'http://${lbPip.properties.ipAddress}/'
output applicationGatewayProductsUrl string = 'http://${agwPip.properties.ipAddress}/products'
output applicationGatewayOrdersUrl string = 'http://${agwPip.properties.ipAddress}/orders'

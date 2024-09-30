provider "azurerm" {
  features {}
  subscription_id = "ec907711-acd7-4191-9983-9577afbe3ce1"
}


data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
  #location = var.location
}

########## Vnet-hub ####################

# virtual network definition 
resource "azurerm_virtual_network" "vnet-hub" {
  name                = "vnethub-sylvain"
  address_space       = ["10.120.0.0/22"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

# subnet externe
resource "azurerm_subnet" "snet-fw-ext" {
  name                 = "snet-fw-ext-sylvain"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-hub.name
  address_prefixes     = ["10.120.0.0/28"]
}

# subnet interne 

resource "azurerm_subnet" "snet-fw-in" {
  name                 = "snet-fw-int-sylvain"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-hub.name
  address_prefixes     = ["10.120.0.16/28"]
}

############### Vnet-client ###################

# virtual network definition 
resource "azurerm_virtual_network" "vnet-client" {
  name                = "vnet-client-sylvain"
  address_space       = ["10.120.4.0/22"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

# subnet client
resource "azurerm_subnet" "snet-client" {
  name                 = "snet-client-sylvain"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-client.name
  address_prefixes     = ["10.120.4.0/24"]
}


############## Vnet-server ####################

# virtual network definition 
resource "azurerm_virtual_network" "vnet-server" {
  name                = "vnet-server-sylvain"
  address_space       = ["10.120.8.0/22"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

# subnet server
resource "azurerm_subnet" "snet-server" {
  name                 = "snet-server-sylvain"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-server.name
  address_prefixes     = ["10.120.8.0/24"]
}

# subnet load balancer 
resource "azurerm_subnet" "snet-lb" {
  name                 = "snet-lb-sylvain"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-server.name
  address_prefixes     = ["10.120.9.0/24"]
}

# NIC nginx server

resource "azurerm_network_interface" "nic-nginxone" {
  name                = "nic-nginxone-sylvain"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet-server.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "nic-nginxtwo" {
  name                = "nic-nginxtwo-sylvain"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet-server.id
    private_ip_address_allocation = "Dynamic"
  }
}


# generate webserver with packer 

data "azurerm_image" "main" {
  name                = var.packer_image_name
  resource_group_name = var.resource_group_name
}


resource "azurerm_availability_set" "avset" {
  name                = "Sylvainavset"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.rg.name

  platform_fault_domain_count  = 2
  platform_update_domain_count = 5
}



#create vm nginx one
resource "azurerm_linux_virtual_machine" "nginx-one" {
  name                            = "nginx-one-sylvain"
  location                        = var.location
  resource_group_name             = data.azurerm_resource_group.rg.name
  size                            = "Standard_B1ls"
  admin_username                  = "admindebian"
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.nic-nginxone.id]
  source_image_id                 = data.azurerm_image.main.id
  availability_set_id             = azurerm_availability_set.avset.id


  admin_ssh_key {
    username   = "admindebian"
    public_key = file("C:/Users/Apprenant/.ssh/id_rsa.pub")
  }


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }


}

#create vm nginx two
resource "azurerm_linux_virtual_machine" "nginx-two" {
  name                            = "nginx-two-sylvain"
  location                        = var.location
  resource_group_name             = data.azurerm_resource_group.rg.name
  size                            = "Standard_B1ls"
  admin_username                  = "admindebian"
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.nic-nginxtwo.id]
  source_image_id                 = data.azurerm_image.main.id
  availability_set_id             = azurerm_availability_set.avset.id


  admin_ssh_key {
    username   = "admindebian"
    public_key = file("C:/Users/Apprenant/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }


}


###### Peering #############################

###### Peering de vnet_hub vers vnet_client

# resource "azurerm_virtual_network_peering" "hub_to_client_peering" {
#   name                         = "hub_to_client_peering"
#   resource_group_name          = var.resource_group_name
#   virtual_network_name         = azurerm_virtual_network.vnet-hub.name
#   remote_virtual_network_id    = azurerm_virtual_network.vnet-client.id
#   allow_virtual_network_access = true
# }

# ####### Peering de vnet_client vers vnet_hub
# resource "azurerm_virtual_network_peering" "client_to_hub_peering" {
#   name                         = "client_to_hub_peering"
#   resource_group_name          = var.resource_group_name
#   virtual_network_name         = azurerm_virtual_network.vnet-client.name
#   remote_virtual_network_id    = azurerm_virtual_network.vnet-hub.id
#   allow_virtual_network_access = true
# }


# ############### Routing table #####################

# resource "azurerm_route_table" "road-tab" {
#   name                = var.route_table_name
#   location            = var.location
#   resource_group_name = data.azurerm_resource_group.rg.name

# }

# resource "azurerm_route" "road" {
#   name                   = "Testroute"
#   resource_group_name    = data.azurerm_resource_group.rg.name
#   route_table_name       = azurerm_route_table.road-tab.name
#   address_prefix         = "0.0.0.0/0"
#   next_hop_type          = "VirtualAppliance"
#   next_hop_in_ip_address = "10.120.0.0"
# }



###### load balancing web server  ############


##### création load balancer interne

# resource "azurerm_lb" "load-balancer" {
#   name                = "load-balancer-sylvain"
#   location            = data.azurerm_resource_group.rg.location
#   resource_group_name = data.azurerm_resource_group.rg.name

#   frontend_ip_configuration {
#     name                       = "InternalLoadBalancer"
#     subnet_id                  = azurerm_subnet.snet-lb.id
#     private_ip_address_version = "IPv4"
#     private_ip_address         = "10.120.9.5"
#   }

# }


# ### création backend address Pool 

# resource "azurerm_lb_backend_address_pool" "bapool" {
#   loadbalancer_id = azurerm_lb.load-balancer.id
#   name            = "BackEndAddressPool"
# }

# ### associer nic-nginxone avec Backend address pool 

# resource "azurerm_network_interface_backend_address_pool_association" "backend1" {
#   network_interface_id    = azurerm_network_interface.nic-nginxone.id
#   ip_configuration_name   = "internal"
#   backend_address_pool_id = azurerm_lb_backend_address_pool.bapool.id
# }


# ### associer nic-nginxtwo avec Backend address pool 

# resource "azurerm_network_interface_backend_address_pool_association" "backend2" {
#   network_interface_id    = azurerm_network_interface.nic-nginxtwo.id
#   ip_configuration_name   = "internal"
#   backend_address_pool_id = azurerm_lb_backend_address_pool.bapool.id
# }






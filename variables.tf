variable "resource_group_name" {
   description = "Name of the resource group in which the Packer image will be created"
   default     = "HbSpkeSylvain"
}


variable "location" {
   default = "northeurope"
   description = "Location where resources will be created"
}


variable "packer_image_name" {
   description = "Name of the Packer image"
   default     = "Nginx"
}

variable "route_table_name" {
  description = "Name of the Azure Route Table"
  default = "RoutingTab"
}

variable "route_entries" {
  description = "List of route entries to be added to the route table"
  type        = list(object({
    name                  = string
    address_prefix        = string
    next_hop_type         = string
    next_hop_in_ip_address = string
  }))
  }


### OpenTelekomCloud Credentials
variable "username" {}
variable "password" {}
variable "domain_name" {}

variable "tenant_name" {}

variable "endpoint" {}

# ### vSphere Credentials
# variable "vsphere_user" {}
# variable "vsphere_password" {}
# variable "vsphere_server" {}

# Info of uploaded image files
variable "obs_imagebucket" {}
# Information of vm migration
variable "vsphere_datacenter" {}
variable "vm_name" {}

# Information of OTC infra
# OTC Network
variable "security_group" {}
variable "subnet_network_id" {}

# variable "fixed_ip_address" {}
# variable "mac_address" {}


# # OTC Security
# variable "kms_key_alias" {
# }
variable "key_pair" {
}

variable "image_size" {
    default = 40
}

# Others
variable "automatic_configuration" {
    default = "true"
}


variable "flavor_id" {
}

variable "az" {
}
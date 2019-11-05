provider "opentelekomcloud" {
  user_name   = "${var.username}"
  password    = "${var.password}"
  tenant_name = "${var.tenant_name}"
  domain_name = "${var.domain_name}"
  auth_url    = "${var.endpoint}"
}

# provider "vsphere" {
#   user           = "${var.vsphere_user}"
#   password       = "${var.vsphere_password}"
#   vsphere_server = "${var.vsphere_server}"
# }

# # data of original vm on vsphere
# data "vsphere_datacenter" "datacenter" {
#   name = "${var.vsphere_datacenter}"
# }

# data "vsphere_virtual_machine" "original_vm" {
#   name          = "${var.vm_name}}"
#   datacenter_id = "${data.vsphere_datacenter.datacenter.id}"
# }


# data of Open Telekom Cloud

# data "opentelekomcloud_networking_secgroup_v2" "secgroup" {
#   name = "${var.security_group}"
# }

data "opentelekomcloud_kms_key_v1" "kms_key" {
  key_alias = "${var.kms_key_alias}"
}

# data "opentelekomcloud_vpc_subnet_v1" "subnet" {
#   name   = "${var.subnet_name}"
#  }


# Create system disk image

resource "opentelekomcloud_ims_image_v2" "sys_image" {
  name   = "${var.vm_name}"
  image_url = "${var.obs_imagebucket}/${var.vm_name}-disk1.vmdk"
  # min_disk = "${data.vsphere_virtual_machine.original_vm.disks.size}"
  min_disk = "${var.image_size}"
  is_config = "${var.automatic_configuration}"
  cmk_id = "${data.opentelekomcloud_kms_key_v1.kms_key.key_id}"
  description = "Image created by auto migration tools."
  tags = {
  }
}

# # Create data disk image

# resource "opentelekomcloud_ims_data_image_v2" "disk_image" {
#   for_each = {
#     image_url = "${var.obs_imagebucket}/${var.vm_name}-disk2.vmdk"
#   }
#   name   = "${var.vm_name}-data-disk1"
  
#   min_disk = "${var.image_size}"
#   cmk_id = "${var.cmk_id_for_encryption}"
#   description = "Data disk image created by auto migration tools."
#   tags = {
#   }
# }

# create port for vm
resource "opentelekomcloud_networking_port_v2" "port_1" {
  name           = "port_1"
  network_id     = "${var.subnet_network_id}"
  admin_state_up = "true"
  mac_address = "${var.mac_address}"
  security_group_ids = [
    "default",
    # "${data.opentelekomcloud_networking_secgroup_v2.secgroup.id}"
  ]
  # fixed_ip =  {
  #   subnet_id = "${var.subnet_network_id}"
  #   ip_address = "${var.fixed_ip_address}"
  # }
}

resource "opentelekomcloud_compute_instance_v2" "migrated_server" {
  name            = "${var.vm_name}"
  image_id        = "${opentelekomcloud_ims_image_v2.sys_image.id}"
  flavor_id       = "${var.flavor_id}"
  key_pair        = "${var.key_pair}"
  availability_zone = "${var.az}"
  network {
    port = "${opentelekomcloud_networking_port_v2.port_1.id}"
  }
}
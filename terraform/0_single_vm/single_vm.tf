provider "opentelekomcloud" {
  user_name   = "${var.username}"
  password    = "${var.password}"
  tenant_name = "${var.tenant_name}"
  domain_name = "${var.domain_name}"
  auth_url    = "${var.endpoint}"
}

provider "vsphere" {
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"
  vsphere_server = "${var.vsphere_server}"

  allow_unverified_ssl = true
}

# data of original vm on vsphere
data "vsphere_datacenter" "datacenter" {
  name = "${var.vsphere_datacenter}"
}

data "vsphere_virtual_machine" "original_vm" {
  name          = "${var.vm_name}"
  datacenter_id = "${data.vsphere_datacenter.datacenter.id}"
}

locals {
  data_disks = slice(data.vsphere_virtual_machine.original_vm.disks, 1, length(data.vsphere_virtual_machine.original_vm.disks))
}

# data of Open Telekom Cloud
data "opentelekomcloud_kms_key_v1" "kms_key" {
  key_alias = "${var.kms_key_alias}"
}

data "opentelekomcloud_vpc_subnet_v1" "subnet" {
  name   = "${var.subnet_name}"
}


# Create system disk image
resource "opentelekomcloud_ims_image_v2" "sys_image" {
  name   = "${var.vm_name}-sys-image"
  image_url = "${var.obs_imagebucket}:${var.vm_name}/${var.vm_name}-disk1.vmdk"
  # min_disk = "${data.vsphere_virtual_machine.original_vm.disks[0].size}"
  min_disk = 40
  is_config = "${var.automatic_configuration}"
  cmk_id = "${data.opentelekomcloud_kms_key_v1.kms_key.key_id}"
  description = "Image created by auto migration tools."
  tags = {
  }
}

# Create data disk image
resource "opentelekomcloud_ims_data_image_v2" "disk_images" {
  count = length(local.data_disks)
  image_url = join("",["${var.obs_imagebucket}:${var.vm_name}/${var.vm_name}-disk", count.index + 2, ".vmdk"])
  name   = join("",["${var.vm_name}-data-disk", count.index])
  os_type = "Linux"
  min_disk = local.data_disks[count.index].size
  cmk_id = "${data.opentelekomcloud_kms_key_v1.kms_key.key_id}"
  description = "Data disk image created by auto migration tools."
  tags = {
  }
}

# Create data disks
resource "opentelekomcloud_blockstorage_volume_v2" "data_disks_OTC" {
  count = length(local.data_disks)
  name   = join("",["${var.vm_name}-data-disk", count.index])
  size   = local.data_disks[count.index].size
  image_id  = "${opentelekomcloud_ims_data_image_v2.disk_images[count.index].id}"
  availability_zone = "${var.az}"
  # metadata    = {
  #   __system__encrypted = "1"
  #   __system__cmkid     = "kms_id"
  # }
}

# Migrated server on OTC 
resource "opentelekomcloud_ecs_instance_v1" "migrated_server" {
  name            = "${var.vm_name}"
  image_id        = "${opentelekomcloud_ims_image_v2.sys_image.id}"
  flavor          = "${var.flavor_id}"
  key_name        = "${var.key_pair}"
  availability_zone = "${var.az}"
  system_disk_type = "SATA"
  # system_disk_size = ""
  auto_recovery = true
  vpc_id   = "${data.opentelekomcloud_vpc_subnet_v1.subnet.vpc_id}"
  nics {
    network_id = "${data.opentelekomcloud_vpc_subnet_v1.subnet.id}"
    ip_address = ""
  }
  security_groups   = ["default"]
}


resource "opentelekomcloud_compute_volume_attach_v2" "data-disks-attachment" {
  count = length(local.data_disks)
  instance_id = "${opentelekomcloud_ecs_instance_v1.migrated_server.id}"
  volume_id   = "${opentelekomcloud_blockstorage_volume_v2.data_disks_OTC[count.index].id}"
}

output "volume_devices" {
  value = "${opentelekomcloud_compute_volume_attach_v2.data-disks-attachment.*.device}"
}
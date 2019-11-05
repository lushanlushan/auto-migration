provider "opentelekomcloud" {
  user_name   = "${var.username}"
  password    = "${var.password}"
  tenant_name = "${var.tenant_name}"
  domain_name = "${var.domain_name}"
  auth_url    = "${var.endpoint}"
}

resource "opentelekomcloud_ims_data_image_v2" "disk_image" {
  name   = "${var.image_name}"
  image_url = "${var.image_url}"
  min_disk = "${var.image_size}"
  cmk_id = "${var.cmk_id_for_encryption}"
  description = "Data disk image created by auto migration tools."
  tags = {
  }
}
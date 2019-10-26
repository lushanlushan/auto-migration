provider "opentelekomcloud" {
  user_name   = "${var.username}"
  password    = "${var.password}"
  tenant_name = "${var.tenant_name}"
  domain_name = "${var.domain_name}"
  auth_url    = "${var.endpoint}"
}

resource "opentelekomcloud_ims_image_v2" "sys_image" {
  name   = "${var.image_name}"
  image_url = "${var.image_url}"
  min_disk = 40
  description = "Image created by auto migration tools."
  tags = {
  }
}
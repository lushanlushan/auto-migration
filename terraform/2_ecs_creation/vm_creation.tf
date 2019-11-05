provider "opentelekomcloud" {
  user_name   = "${var.username}"
  password    = "${var.password}"
  tenant_name = "${var.tenant_name}"
  domain_name = "${var.domain_name}"
  auth_url    = "${var.endpoint}"
}

# create port for vm
resource "opentelekomcloud_networking_port_v2" "port_1" {
  name           = "port_1"
  network_id     = "${var.network_id}"
  admin_state_up = "true"
  mac_address = "${var.mac_address}"
  security_group_ids = "default"
  fixed_ip =  {
    subnet_id = "${var.subnet_id}"
    ip_address = "${var.ip_address}"
  }
}

resource "opentelekomcloud_compute_instance_v2" "migrated_server" {
  name            = "${var.vm_name}"
  image_id        = "${var.image_id}"
  flavor_id       = "${var.flavor_id}"
  key_pair        = "${var.key_pair}"
  availability_zone = "${var.az}"
  network {
    port = "${opentelekomcloud_networking_port_v2.port_1.id}"
  }
}
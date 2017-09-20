resource "openstack_networking_network_v2" "bosh-network" {
  region = "${var.os_region}"
  name = "${var.prefix}-bosh-network"
}

resource "openstack_networking_subnet_v2" "bosh-subnet" {
  region = "${var.os_region}"
  name = "${var.prefix}-bosh-subnet"
  network_id = "${openstack_networking_network_v2.bosh-network.id}"
  cidr = "${var.cidr}"
  gateway_ip = "${var.gateway}"
  dns_nameservers = "${var.dns}"
}

resource "openstack_networking_router_v2" "bosh-router" {
  region = "${var.os_region}"
  name = "${var.prefix}-bosh-router"
  external_gateway = "${var.external_network_uuid}"
}

resource "openstack_networking_router_interface_v2" "bosh-router-interface" {
  region = "${var.os_region}"
  router_id = "${openstack_networking_router_v2.bosh-router.id}"
  subnet_id = "${openstack_networking_subnet_v2.bosh-subnet.id}"
}


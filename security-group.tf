resource "openstack_networking_secgroup_v2" "bosh-secgroup" {
  count = "${var.resource_count}"

  name = "${var.prefix}-bosh-secgroup"
  description = "BOSH Security Group (${var.prefix})"
  region = "${var.os_region}"
}

resource "openstack_networking_secgroup_rule_v2" "bosh-ssh" {
  count = "${var.resource_count}"

  security_group_id = "${openstack_networking_secgroup_v2.bosh-secgroup.id}"
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 22
  port_range_max = 22
  remote_ip_prefix = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "bosh-agent" {
  count = "${var.resource_count}"

  security_group_id = "${openstack_networking_secgroup_v2.bosh-secgroup.id}"
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 6868
  port_range_max = 6868
  remote_ip_prefix = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "bosh-director" {
  count = "${var.resource_count}"

  security_group_id = "${openstack_networking_secgroup_v2.bosh-secgroup.id}"
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 25555
  port_range_max = 25555
  remote_ip_prefix = "0.0.0.0/0"
}

resource "openstack_networking_secgroup_rule_v2" "bosh-internal" {
  count = "${var.resource_count}"

  security_group_id = "${openstack_networking_secgroup_v2.bosh-secgroup.id}"
  remote_group_id = "${openstack_networking_secgroup_v2.bosh-secgroup.id}"
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "tcp"
  port_range_min = 1
  port_range_max = 65535
}

resource "openstack_networking_secgroup_rule_v2" "bosh-icmp" {
  count = "${var.resource_count}"

  security_group_id = "${openstack_networking_secgroup_v2.bosh-secgroup.id}"
  remote_group_id = "${openstack_networking_secgroup_v2.bosh-secgroup.id}"
  direction = "ingress"
  ethertype = "IPv4"
  protocol = "icmp"
}

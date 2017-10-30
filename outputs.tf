output "bosh_network" {
  value = "${var.resource_count ? join("", openstack_networking_network_v2.bosh-network.*.name) : ""}"
}

output "secgroup_id" {
  value = "${var.resource_count ? join("", openstack_networking_secgroup_v2.bosh-secgroup.*.id) : ""}"
}

output "deploy-bosh-id" {
  value = "${var.resource_count ? join("", null_resource.deploy-bosh.*.id) : ""}"
}

output "jumpbox_ip" {
  value = "${var.resource_count ? join("", openstack_compute_floatingip_associate_v2.jumpbox-floating-ip.*.floating_ip) : ""}"
}

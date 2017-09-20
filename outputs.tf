output "bosh-network-name" {
  value = "${openstack_networking_network_v2.bosh-network.name}"
}

output "bosh-secgroup-id" {
  value = "${openstack_networking_secgroup_v2.bosh-secgroup.id}"
}

output "deploy-bosh-id" {
  value = "${null_resource.deploy-bosh.id}"
}

output "bosh-floating-ip" {
  value = "${openstack_compute_floatingip_associate_v2.bosh-floating-ip.floating_ip}"
}

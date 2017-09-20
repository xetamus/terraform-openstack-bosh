data "template_file" "vars-yml" {
  template = "${file("${path.module}/templates/vars.yml.tpl")}"

  vars {
    director_name = "${var.director_name}"
    auth_url = "${var.os_auth_url}"
    domain = "${var.os_domain_name}"
    project = "${var.os_tenant}"
    username = "${var.os_username}"
    password = "${var.os_password}"
    region = "${var.os_region}"
    key = "${openstack_compute_keypair_v2.bosh-keypair.name}"
    private_key = "${replace(chomp(file("${var.ssh_privkey}")), "\n", "\\n")}"
    secgroup = "${openstack_networking_secgroup_v2.bosh-secgroup.name}"
    az = "${var.bosh_az}"
    cidr = "${var.cidr}"
    gw = "${var.gateway}"
    bosh_ip = "${var.director_ip}"
    net_id = "${openstack_networking_network_v2.bosh-network.id}"
  }
}

data "template_file" "cloud-config" {
  template = "${file("${path.module}/templates/cloud-config.yml.tpl")}"

  vars {
    az = "${var.bosh_az}"
    cidr = "${var.cidr}"
    gw = "${var.gateway}"
    net_id = "${openstack_networking_network_v2.bosh-network.id}"
    dns = "${join(",", "${var.dns}")}"
    reserved = "${var.reserved_ranges}"
  }
}

data "template_file" "install_bosh" {
  template = "${file("${path.module}/templates/install_bosh.sh.tpl")}"

  vars {
    bosh_cli_version = "${var.bosh_cli_version}"
    director_ip = "${var.director_ip}"
    prefix = "${var.prefix}"
  }
}

resource "openstack_compute_keypair_v2" "bosh-keypair" {
  name = "${var.prefix}-bosh"
  public_key =  "${chomp(file("${var.ssh_pubkey}"))}"
}

resource "openstack_compute_floatingip_v2" "jumpbox-floating-ip" {
  pool = "${var.external_network}"
}

resource "openstack_compute_instance_v2" "bosh-jumpbox" {
  region = "${var.os_region}"
  name = "${var.prefix}-bosh-jumpbox"
  image_name = "${var.image}"
  flavor_name = "${var.flavor}"
  security_groups = ["${openstack_networking_secgroup_v2.bosh-secgroup.name}"]
  key_pair = "${openstack_compute_keypair_v2.bosh-keypair.name}"

  network {
    name = "${openstack_networking_network_v2.bosh-network.name}"
    fixed_ip_v4 = "${var.internal_ip}"
  }
}

resource "openstack_compute_floatingip_associate_v2" "jumpbox-floating-ip" {
  depends_on = ["openstack_networking_secgroup_rule_v2.bosh-agent",
                "openstack_networking_secgroup_rule_v2.bosh-director",
                "openstack_networking_secgroup_rule_v2.bosh-ssh"]

  floating_ip = "${openstack_compute_floatingip_v2.jumpbox-floating-ip.address}"
  instance_id = "${openstack_compute_instance_v2.bosh-jumpbox.id}"
  fixed_ip = "${openstack_compute_instance_v2.bosh-jumpbox.network.0.fixed_ip_v4}"

  connection {
    type = "ssh"
    host = "${openstack_compute_floatingip_v2.jumpbox-floating-ip.address}"
    user = "ubuntu"
    private_key = "${chomp(file("${var.ssh_privkey}"))}"
  }

  provisioner "remote-exec" {
    when = "destroy"
    inline = [
      "sudo bosh -n delete-env bosh.yml -o cpi.yml -l vars.yml --vars-store creds.yml"
    ]
  }
}

resource "null_resource" "deploy-bosh" {
  triggers {
    floating_ip_associated = "${openstack_compute_floatingip_associate_v2.jumpbox-floating-ip.floating_ip}"
  }

  connection {
    type = "ssh"
    host = "${openstack_compute_floatingip_associate_v2.jumpbox-floating-ip.floating_ip}"
    user = "ubuntu"
    private_key = "${chomp(file("${var.ssh_privkey}"))}"
  }

  provisioner "file" {
    content = "${data.template_file.vars-yml.rendered}"
    destination = "~/vars.yml"
  }

  provisioner "file" {
    content = "${data.template_file.cloud-config.rendered}"
    destination = "~/cloud-config.yml"
  }

  provisioner "file" {
    content = "${data.template_file.install_bosh.rendered}"
    destination = "~/install_bosh.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo bash install_bosh.sh"
    ]
  }
}

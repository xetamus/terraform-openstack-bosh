azs:
- name: ${az}
  cloud_properties:
    availability_zone: ${az}

vm_types:
- name: default
  cloud_properties:
    instance_type: m1.small
- name: small
  cloud_properties:
    instance_type: m1.small
- name: medium
  cloud_properties:
    instance_type: m1.medium
- name: large
  cloud_properties:
    instance_type: m1.xlarge
- name: xlarge
  cloud_properties:
    instance_type: m1.xlarge

disk_types:
- name: default
  disk_size: 3000
- name: small
  disk_size: 3000
- name: medium
  disk_size: 25_000
- name: large
  disk_size: 50_000
- name: xlarge
  disk_size: 100_000

networks:
- name: default
  type: manual
  subnets:
  - range: ${cidr}
    gateway: ${gw}
    azs: [${az}]
    dns: [${dns}]
    reserved: [${reserved}]
    cloud_properties:
      net_id: ${net_id}
- name: vip
  type: vip

compilation:
  workers: 5
  reuse_compilation_vms: true
  az: ${az}
  vm_type: default
  network: default

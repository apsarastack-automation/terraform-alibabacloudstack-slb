data "alibabacloudstack_images" "default" {
  name_regex  = "^ubuntu_"
  most_recent = true
  owners      = "system"
}

data "alibabacloudstack_instance_types" "default" {
  availability_zone = var.zone_id
  cpu_core_count    = 1
  memory_size       = 1
}

resource "alibabacloudstack_ecs_securitygroup" "default" {
  name   = "${var.name}-sg"
  vpc_id = var.vpc_id
}

resource "alibabacloudstack_security_group_rule" "default" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "80/80"
  priority          = 1
  security_group_id = alibabacloudstack_ecs_securitygroup.default.id
  cidr_ip           = "172.16.0.0/24"
}

resource "alibabacloudstack_ecs_instance" "web" {
  count             = var.instance_count
  image_id          = data.alibabacloudstack_images.default.images[0].id
  instance_type     = data.alibabacloudstack_instance_types.default.instance_types[0].id
  vswitch_id        = var.vswitch_id
  security_groups   = [alibabacloudstack_ecs_securitygroup.default.id]
  instance_name     = "${var.name}-web-${count.index + 1}"
  system_disk_size  = 20
}
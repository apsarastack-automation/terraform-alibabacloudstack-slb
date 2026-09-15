# most_recent=true makes images[0] deterministic; no check block needed
data "alibabacloudstack_images" "default" {
  name_regex  = "^ubuntu_"
  most_recent = true
  owners      = "system"
}

data "alibabacloudstack_zones" "default" {
  available_resource_creation = "VSwitch"
  enable_details             = true
}

data "alibabacloudstack_instance_types" "default" {
  availability_zone = data.alibabacloudstack_zones.default.zones[0].id
  sorted_by         = "CPU"
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
  system_disk_category = length(data.alibabacloudstack_zones.default.zones) > 0 && length(data.alibabacloudstack_zones.default.zones[0].available_disk_categories) > 0 ? data.alibabacloudstack_zones.default.zones[0].available_disk_categories[0] : "cloud_efficiency"
  system_disk_size  = 20
}
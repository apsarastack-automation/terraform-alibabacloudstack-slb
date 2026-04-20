data "alibabacloudstack_zones" "default" {
  available_resource_creation = "VSwitch"
  enable_details              = true
}

resource "alibabacloudstack_vpc_vpc" "default" {
  vpc_name   = "${var.name}-vpc"
  cidr_block = "172.16.0.0/16"
}

resource "alibabacloudstack_vpc_vswitch" "default" {
  name       = "${var.name}-vsw"
  vpc_id     = alibabacloudstack_vpc_vpc.default.id
  cidr_block = "172.16.0.0/24"
  zone_id    = data.alibabacloudstack_zones.default.zones[0].id
}
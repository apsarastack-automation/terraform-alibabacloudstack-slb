output "vpc_id" {
  description = "The ID of the created VPC"
  value       = alibabacloudstack_vpc_vpc.default.id
}

output "vswitch_id" {
  description = "The ID of the created VSwitch"
  value       = alibabacloudstack_vpc_vswitch.default.id
}

output "zone_id" {
  description = "The zone ID used"
  value       = data.alibabacloudstack_zones.default.zones[0].id
}
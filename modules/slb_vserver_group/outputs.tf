output "id" {
  description = "The ID of the VServer Group."
  value       = alibabacloudstack_slb_vservergroup.default.id
}

output "load_balancer_id" {
  description = "The Load Balancer ID which is used to launch a new VServer Group."
  value       = alibabacloudstack_slb_vservergroup.default.load_balancer_id
}

output "name" {
  description = "The name of the VServer Group."
  value       = alibabacloudstack_slb_vservergroup.default.name
}

output "vserver_group_name" {
  description = "The name of the VServer Group (alias)."
  value       = alibabacloudstack_slb_vservergroup.default.vserver_group_name
}

output "servers" {
  description = "A list of ECS instances that have been added."
  value       = alibabacloudstack_slb_vservergroup.default.servers
}
output "id" {
  description = "The ID of the load balancer."
  value       = alibabacloudstack_slb_loadbalancer.default.id
}

output "name" {
  description = "The name of the load balancer."
  value       = alibabacloudstack_slb_loadbalancer.default.name
}

output "address" {
  description = "The IP address of the load balancer."
  value       = alibabacloudstack_slb_loadbalancer.default.address
}

output "address_type" {
  description = "The address type of the load balancer."
  value       = alibabacloudstack_slb_loadbalancer.default.address_type
}

output "specification" {
  description = "The specification of the load balancer."
  value       = alibabacloudstack_slb_loadbalancer.default.specification
}

output "vswitch_id" {
  description = "The ID of the VSwitch associated with the load balancer."
  value       = alibabacloudstack_slb_loadbalancer.default.vswitch_id
}

output "network_type" {
  description = "The network type of the load balancer."
  value       = alibabacloudstack_slb_loadbalancer.default.network_type
}
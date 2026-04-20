output "id" {
  description = "The ID of the load balancer listener. Its format as '<load_balancer_id>:<protocol>:<frontend_port>'."
  value       = alibabacloudstack_slb_listener.default.id
}

output "description" {
  description = "The listener description."
  value       = alibabacloudstack_slb_listener.default.description
}
output "instance_ids" {
  description = "The IDs of the created ECS instances"
  value       = alibabacloudstack_ecs_instance.web[*].id
}

output "instance_ips" {
  description = "The private IPs of the created ECS instances"
  value       = alibabacloudstack_ecs_instance.web[*].private_ip
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = alibabacloudstack_ecs_securitygroup.default.id
}
output "slb_id" {
  description = "The ID of the load balancer."
  value       = module.slb_instance.id
}

output "slb_name" {
  description = "The name of the load balancer."
  value       = module.slb_instance.name
}

output "address" {
  description = "The IP address of the load balancer."
  value       = module.slb_instance.address
}

output "address_type" {
  description = "The address type of the load balancer."
  value       = module.slb_instance.address_type
}

output "specification" {
  description = "The specification of the load balancer."
  value       = module.slb_instance.specification
}

output "vswitch_id" {
  description = "The ID of the VSwitch associated with the load balancer."
  value       = module.slb_instance.vswitch_id
}

output "listener_ids" {
  description = "List of listener IDs created."
  value       = module.slb_listener[*].id
}

output "certificate_id" {
  description = "The ID of the SSL certificate (if created)."
  value       = length(alibabacloudstack_slb_server_certificate.default) > 0 ? alibabacloudstack_slb_server_certificate.default[0].id : ""
}
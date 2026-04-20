output "slb_id" {
  description = "The ID of the created SLB instance."
  value       = module.slb_instance.id
}

output "slb_address" {
  description = "The IP address of the created SLB instance."
  value       = module.slb_instance.address
}

output "vserver_group_id" {
  description = "The ID of the VServer Group."
  value       = module.slb_vserver_group.id
}

output "listener_id" {
  description = "The ID of the HTTP listener."
  value       = module.slb_listener.id
}
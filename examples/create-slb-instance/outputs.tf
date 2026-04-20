output "slb_id" {
  description = "The ID of the created SLB instance."
  value       = module.slb_instance.id
}

output "slb_address" {
  description = "The IP address of the created SLB instance."
  value       = module.slb_instance.address
}

output "slb_name" {
  description = "The name of the created SLB instance."
  value       = module.slb_instance.name
}
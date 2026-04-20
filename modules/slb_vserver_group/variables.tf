variable "load_balancer_id" {
  description = "The ID of the SLB instance."
  type        = string
}

variable "name" {
  description = "Name of the virtual server group."
  type        = string
  default     = ""
}

variable "vserver_group_name" {
  description = "Alternative name field for the VServer Group. Use either 'name' or 'vserver_group_name'."
  type        = string
  default     = ""
}

variable "servers" {
  description = "A list of backend servers to be added. At most 20 ECS instances can be supported in one resource."
  type = list(object({
    server_ids = list(string)
    port       = number
    weight     = optional(number, 100)
    type       = optional(string, "ecs")
  }))
  default = []
}

variable "delete_protection_validation" {
  description = "Checking DeleteProtection of SLB instance before deleting. If true, this resource will not be deleted when its SLB instance enabled DeleteProtection."
  type        = bool
  default     = false
}
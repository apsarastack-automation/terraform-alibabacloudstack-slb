variable "name" {
  description = "The name of the SLB instance and related resources."
  type        = string
  default     = "tf-example-slb-vserver"
}

variable "vswitch_id" {
  description = "The ID of the VSwitch to launch the SLB in."
  type        = string
}

variable "specification" {
  description = "The specification of the SLB instance."
  type        = string
  default     = "slb.s2.small"
}

variable "backend_servers" {
  description = "List of backend servers to attach to the VServer group."
  type = list(object({
    server_ids = list(string)
    port       = number
    weight     = optional(number, 100)
    type       = optional(string, "ecs")
  }))
  default = []
}
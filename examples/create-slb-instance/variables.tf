variable "name" {
  description = "The name of the SLB instance."
  type        = string
  default     = "tf-example-slb"
}

variable "vswitch_id" {
  description = "The ID of the VSwitch to launch the SLB in."
  type        = string
}

variable "specification" {
  description = "The specification of the SLB instance."
  type        = string
  default     = "slb.s1.small"
}
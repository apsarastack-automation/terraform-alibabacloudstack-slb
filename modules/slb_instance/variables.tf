variable "name" {
  description = "The name of the SLB instance. This name must be unique within your AlibabaCloudStack account, can have a maximum of 80 characters, must contain only alphanumeric characters or hyphens."
  type        = string
}

variable "address_type" {
  description = "The network type of the SLB instance. Valid values: internet, intranet. If the load balancer is launched in VPC, this value must be intranet."
  type        = string
  default     = "intranet"
}

variable "vswitch_id" {
  description = "The ID of the VSwitch to launch the SLB in. Required for a VPC SLB."
  type        = string
  default     = ""
}

variable "specification" {
  description = "The specification of the Server Load Balancer instance. Valid values: slb.s1.small, slb.s2.small, slb.s2.medium, slb.s3.small, slb.s3.medium, slb.s3.large, slb.s4.large."
  type        = string
  default     = ""
}

variable "network_type" {
  description = "The network type of the SLB instance. Valid values: classic, vpc."
  type        = string
  default     = "classic"
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}
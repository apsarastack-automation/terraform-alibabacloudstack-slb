variable "name" {
  description = "The name prefix for test resources"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "vswitch_id" {
  description = "The ID of the VSwitch"
  type        = string
}

variable "zone_id" {
  description = "The zone ID"
  type        = string
}

variable "instance_count" {
  description = "Number of ECS instances to create"
  type        = number
  default     = 2
}
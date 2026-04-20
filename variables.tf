# General Settings
variable "name" {
  description = "The name of the SLB instance. This name must be unique within your AlibabaCloudStack account, can have a maximum of 80 characters, must contain only alphanumeric characters or hyphens."
  type        = string
}

variable "address_type" {
  description = "The network type of the SLB instance. Valid values: internet, intranet. If the load balancer is launched in VPC, this value must be intranet."
  type        = string
  default     = "intranet"

  validation {
    condition     = contains(["internet", "intranet"], var.address_type)
    error_message = "Valid values for address_type are: internet, intranet."
  }
}

variable "vswitch_id" {
  description = "The ID of the VSwitch to launch the SLB in. Required for a VPC SLB. If address_type is set to internet, this field will be ignored."
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

  validation {
    condition     = contains(["classic", "vpc"], var.network_type)
    error_message = "Valid values for network_type are: classic, vpc."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

# Listener Configuration
variable "listeners" {
  description = "List of listener configurations."
  type = list(object({
    frontend_port             = number
    backend_port              = number
    protocol                  = optional(string, "http")
    bandwidth                 = optional(number, -1)
    scheduler                 = optional(string, "wrr")
    sticky_session            = optional(string, "off")
    sticky_session_type       = optional(string, "insert")
    cookie_timeout            = optional(number, 86400)
    cookie                    = optional(string, "terraform-slb-cookie")
    persistence_timeout       = optional(number, 3600)
    established_timeout       = optional(number, 900)
    health_check              = optional(string, "off")
    health_check_type         = optional(string, "tcp")
    health_check_domain       = optional(string, "")
    health_check_uri          = optional(string, "/")
    health_check_connect_port = optional(number, -520)
    healthy_threshold         = optional(number, 3)
    unhealthy_threshold       = optional(number, 3)
    health_check_timeout      = optional(number, 5)
    health_check_interval     = optional(number, 2)
    health_check_http_code    = optional(string, "http_2xx")
    enable_http2              = optional(string, "on")
  }))
  default = []
}

# Backend Servers
variable "backend_servers" {
  description = "List of backend servers to attach to the SLB."
  type = list(object({
    server_id = string
    port      = number
    weight    = optional(number, 100)
  }))
  default = []
}

# SSL Certificate
variable "server_certificate" {
  description = "The public key certificate for HTTPS listeners."
  type        = string
  default     = ""
}

variable "private_key" {
  description = "The private key corresponding to the certificate."
  type        = string
  default     = ""
}
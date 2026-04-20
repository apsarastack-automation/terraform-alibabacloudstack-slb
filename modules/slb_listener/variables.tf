variable "load_balancer_id" {
  description = "ID of the load balancing instance."
  type        = string
}

variable "frontend_port" {
  description = "Port used by the Server Load Balancer instance frontend. Valid value range: [1-65535]."
  type        = number
}

variable "backend_port" {
  description = "Port used by the Server Load Balancer instance backend. Valid value range: [1-65535]."
  type        = number
}

variable "protocol" {
  description = "The protocol to listen on. Valid values are http, https, tcp, udp."
  type        = string
  default     = "http"
}

variable "bandwidth" {
  description = "Bandwidth peak of Listener. For the public network instance charged per traffic consumed, the Bandwidth on Listener can be set to -1, indicating the bandwidth peak is unlimited. Valid values are [-1, 1-5000] in Mbps."
  type        = number
  default     = -1
}

variable "scheduler" {
  description = "Scheduling algorithm. Valid values are wrr, rr, and wlc."
  type        = string
  default     = "wrr"
}

variable "server_group_id" {
  description = "The bound server group ID."
  type        = string
  default     = ""
}

variable "master_slave_server_group_id" {
  description = "The ID of the primary/secondary server group. NOTE: You cannot set both 'server_group_id' and 'master_slave_server_group_id'."
  type        = string
  default     = ""
}

variable "sticky_session" {
  description = "Whether to enable session persistence. Valid values are on and off."
  type        = string
  default     = "off"
}

variable "sticky_session_type" {
  description = "Mode for handling the cookie. If sticky_session is 'on', it is mandatory. Valid values are insert and server."
  type        = string
  default     = "insert"
}

variable "cookie_timeout" {
  description = "Cookie timeout. It is mandatory when sticky_session is 'on' and sticky_session_type is 'insert'. Valid value range: [1-86400] in seconds."
  type        = number
  default     = 86400
}

variable "cookie" {
  description = "The cookie configured on the server. It is mandatory when sticky_session is 'on' and sticky_session_type is 'server'."
  type        = string
  default     = "terraform-slb-cookie"
}

variable "persistence_timeout" {
  description = "Timeout of connection persistence. Valid value range: [1-3600] in seconds."
  type        = number
  default     = 3600
}

variable "health_check" {
  description = "Whether to enable health check. Valid values are on and off. TCP and UDP listener's HealthCheck is always on."
  type        = string
  default     = "off"
}

variable "health_check_type" {
  description = "Type of health check. Valid values are: tcp and http."
  type        = string
  default     = "tcp"
}

variable "health_check_domain" {
  description = "Domain name used for health check. When it used to launch TCP listener, health_check_type must be 'http'."
  type        = string
  default     = ""
}

variable "health_check_uri" {
  description = "URI used for health check. When it used to launch TCP listener, health_check_type must be 'http'. Its length is limited to 1-80 and it must start with '/'."
  type        = string
  default     = "/"
}

variable "health_check_connect_port" {
  description = "Port used for health check. Valid value range: [1-65535] or -520 for default backend port."
  type        = number
  default     = -520
}

variable "healthy_threshold" {
  description = "Threshold determining the result of the health check is success. Valid value range: [1-10]."
  type        = number
  default     = 3
}

variable "unhealthy_threshold" {
  description = "Threshold determining the result of the health check is fail. Valid value range: [1-10]."
  type        = number
  default     = 3
}

variable "health_check_timeout" {
  description = "Maximum timeout of each health check response. Valid value range: [1-300] in seconds."
  type        = number
  default     = 5
}

variable "health_check_interval" {
  description = "Time interval of health checks. Valid value range: [1-50] in seconds."
  type        = number
  default     = 2
}

variable "health_check_http_code" {
  description = "Regular health check HTTP status code. Multiple codes are segmented by ','. Valid values are: http_2xx, http_3xx, http_4xx, http_5xx."
  type        = string
  default     = "http_2xx"
}

variable "server_certificate_id" {
  description = "SLB Server certificate ID. It is required when protocol is 'https'."
  type        = string
  default     = ""
}

variable "ca_certificate_id" {
  description = "The ID of the certification authority (CA) certificate."
  type        = string
  default     = ""
}

variable "gzip" {
  description = "Whether to enable 'Gzip Compression'."
  type        = bool
  default     = true
}

variable "x_forwarded_for" {
  description = "Whether to set additional HTTP Header field 'X-Forwarded-For'."
  type        = map(string)
  default     = null
}

variable "established_timeout" {
  description = "Timeout of tcp listener established connection idle timeout. Valid value range: [10-900] in seconds."
  type        = number
  default     = 900
}

variable "acl_status" {
  description = "Specifies whether to enable access control. Valid values: on, off."
  type        = string
  default     = "off"
}

variable "acl_type" {
  description = "The type of the network ACL. Valid values: black, white."
  type        = string
  default     = "white"
}

variable "acl_id" {
  description = "The ID of the network ACL that is associated with the listener."
  type        = string
  default     = ""
}

variable "enable_http2" {
  description = "Specifies whether to enable HTTP/2. Valid values: on, off."
  type        = string
  default     = "on"
}

variable "tls_cipher_policy" {
  description = "The Transport Layer Security (TLS) security policy."
  type        = string
  default     = "tls_cipher_policy_1_0"
}
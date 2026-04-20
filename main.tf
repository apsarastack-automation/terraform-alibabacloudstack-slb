locals {
  common_tags = merge(
    {
      "ManagedBy" = "Terraform"
    },
    var.tags
  )
}

# SLB Instance
module "slb_instance" {
  source = "./modules/slb_instance"

  name          = var.name
  address_type  = var.address_type
  vswitch_id    = var.vswitch_id
  specification = var.specification
  network_type  = var.network_type
  tags          = local.common_tags
}

# SSL Certificate (if provided)
resource "alibabacloudstack_slb_server_certificate" "default" {
  count = var.server_certificate != "" && var.private_key != "" ? 1 : 0

  name               = "${var.name}-cert"
  server_certificate = var.server_certificate
  private_key        = var.private_key
}

# Listeners
module "slb_listener" {
  source = "./modules/slb_listener"
  count  = length(var.listeners)

  load_balancer_id = module.slb_instance.id
  frontend_port    = var.listeners[count.index].frontend_port
  backend_port     = var.listeners[count.index].backend_port
  protocol         = var.listeners[count.index].protocol
  bandwidth        = lookup(var.listeners[count.index], "bandwidth", -1)
  scheduler        = lookup(var.listeners[count.index], "scheduler", "wrr")

  # Session persistence
  sticky_session      = lookup(var.listeners[count.index], "sticky_session", "off")
  sticky_session_type = lookup(var.listeners[count.index], "sticky_session_type", "insert")
  cookie_timeout      = lookup(var.listeners[count.index], "cookie_timeout", 86400)
  cookie              = lookup(var.listeners[count.index], "cookie", "terraform-slb-cookie")

  # Health check
  health_check            = lookup(var.listeners[count.index], "health_check", "off")
  health_check_type       = lookup(var.listeners[count.index], "health_check_type", "tcp")
  health_check_domain     = lookup(var.listeners[count.index], "health_check_domain", "")
  health_check_uri        = lookup(var.listeners[count.index], "health_check_uri", "/")
  health_check_connect_port = lookup(var.listeners[count.index], "health_check_connect_port", -520)
  healthy_threshold       = lookup(var.listeners[count.index], "healthy_threshold", 3)
  unhealthy_threshold     = lookup(var.listeners[count.index], "unhealthy_threshold", 3)
  health_check_timeout    = lookup(var.listeners[count.index], "health_check_timeout", 5)
  health_check_interval   = lookup(var.listeners[count.index], "health_check_interval", 2)
  health_check_http_code  = lookup(var.listeners[count.index], "health_check_http_code", "http_2xx")

  # SSL/TLS
  server_certificate_id = var.listeners[count.index].protocol == "https" && var.server_certificate != "" ? alibabacloudstack_slb_server_certificate.default[0].id : ""
  enable_http2          = lookup(var.listeners[count.index], "enable_http2", "on")

  # TCP specific
  persistence_timeout = lookup(var.listeners[count.index], "persistence_timeout", 3600)
  established_timeout = lookup(var.listeners[count.index], "established_timeout", 900)
}

# Backend Servers (if provided)
resource "alibabacloudstack_slb_backend_server" "default" {
  count = length(var.backend_servers) > 0 ? 1 : 0

  load_balancer_id = module.slb_instance.id

  backend_servers {
    server_id = var.backend_servers[count.index].server_id
    weight    = lookup(var.backend_servers[count.index], "weight", 100)
  }
}
resource "alibabacloudstack_slb_listener" "default" {
  load_balancer_id = var.load_balancer_id
  frontend_port    = var.frontend_port
  backend_port     = var.backend_port
  protocol         = var.protocol
  bandwidth        = var.bandwidth
  scheduler        = var.scheduler

  # Server groups
  server_group_id              = var.server_group_id
  master_slave_server_group_id = var.master_slave_server_group_id

  # Session persistence
  sticky_session      = var.sticky_session
  sticky_session_type = var.sticky_session_type
  cookie_timeout      = var.cookie_timeout
  cookie              = var.cookie
  persistence_timeout = var.persistence_timeout

  # Health check
  health_check            = var.health_check
  health_check_type       = var.health_check_type
  health_check_domain     = var.health_check_domain
  health_check_uri        = var.health_check_uri
  health_check_connect_port = var.health_check_connect_port
  healthy_threshold       = var.healthy_threshold
  unhealthy_threshold     = var.unhealthy_threshold
  health_check_timeout    = var.health_check_timeout
  health_check_interval   = var.health_check_interval
  health_check_http_code  = var.health_check_http_code

  # SSL/TLS
  server_certificate_id = var.server_certificate_id
  ca_certificate_id     = var.ca_certificate_id
  enable_http2          = var.enable_http2
  tls_cipher_policy     = var.tls_cipher_policy

  # TCP specific
  established_timeout = var.established_timeout

  # ACL
  acl_status = var.acl_status
  acl_type   = var.acl_type
  acl_id     = var.acl_id

  # Compression
  gzip = var.gzip

  # X-Forwarded-For
  dynamic "x_forwarded_for" {
    for_each = var.x_forwarded_for != null ? [var.x_forwarded_for] : []
    content {
      retrive_client_ip = lookup(x_forwarded_for.value, "retrive_client_ip", true)
      retrive_slb_id    = lookup(x_forwarded_for.value, "retrive_slb_id", false)
      retrive_slb_ip    = lookup(x_forwarded_for.value, "retrive_slb_ip", false)
      retrive_slb_proto = lookup(x_forwarded_for.value, "retrive_slb_proto", false)
    }
  }
}
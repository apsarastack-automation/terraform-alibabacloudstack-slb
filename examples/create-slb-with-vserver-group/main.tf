module "slb_instance" {
  source = "../../modules/slb_instance"

  name          = var.name
  address_type  = "intranet"
  vswitch_id    = var.vswitch_id
  specification = var.specification

  tags = {
    Environment = "Test"
    Example     = "create-slb-with-vserver-group"
  }
}

module "slb_vserver_group" {
  source = "../../modules/slb_vserver_group"

  load_balancer_id = module.slb_instance.id
  name             = "${var.name}-web-servers"

  servers = var.backend_servers
}

module "slb_listener" {
  source = "../../modules/slb_listener"

  load_balancer_id = module.slb_instance.id
  frontend_port    = 80
  backend_port     = 80
  protocol         = "http"
  bandwidth        = 50
  scheduler        = "wrr"
  server_group_id  = module.slb_vserver_group.id

  health_check      = "on"
  health_check_type = "http"
  health_check_uri  = "/"
}
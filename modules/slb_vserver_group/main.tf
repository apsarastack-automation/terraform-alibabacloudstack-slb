resource "alibabacloudstack_slb_vservergroup" "default" {
  load_balancer_id = var.load_balancer_id
  name             = var.name != "" ? var.name : var.vserver_group_name

  dynamic "servers" {
    for_each = var.servers
    content {
      server_ids = servers.value.server_ids
      port       = servers.value.port
      weight     = lookup(servers.value, "weight", 100)
      type       = lookup(servers.value, "type", "ecs")
    }
  }

  delete_protection_validation = var.delete_protection_validation
}
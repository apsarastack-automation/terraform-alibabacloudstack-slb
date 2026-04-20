resource "alibabacloudstack_slb_loadbalancer" "default" {
  name          = var.name
  address_type  = var.address_type
  vswitch_id    = var.vswitch_id
  specification = var.specification
  network_type  = var.network_type
  tags          = var.tags
}
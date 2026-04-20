module "slb_instance" {
  source = "../../modules/slb_instance"

  name          = var.name
  address_type  = "intranet"
  vswitch_id    = var.vswitch_id
  specification = var.specification

  tags = {
    Environment = "Test"
    CreatedBy   = "Terraform"
    Example     = "create-slb-instance"
  }
}
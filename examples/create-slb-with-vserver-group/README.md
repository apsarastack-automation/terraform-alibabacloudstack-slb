=====
# Create SLB with VServer Group Example

This example demonstrates how to create an SLB (Server Load Balancer) with virtual server groups on Alibaba Cloud Stack.

## Overview

This example creates:
- An SLB instance
- A virtual server group with multiple backend servers
- An HTTP listener bound to the virtual server group
- ECS instances as backend servers (optional)

## Usage

### Basic Usage with Existing ECS Instances

```hcl
module "slb_instance" {
  source = "../../modules/slb_instance"

  name          = "web-tier-slb"
  address_type  = "intranet"
  vswitch_id    = "vsw-xxxxxxxx"
  specification = "slb.s2.small"
}

module "slb_vserver_group" {
  source = "../../modules/slb_vserver_group"

  load_balancer_id = module.slb_instance.id
  name             = "web-servers"

  servers = [
    {
      server_ids = ["i-xxxxxxxx", "i-yyyyyyyy"]
      port       = 80
      weight     = 100
      type       = "ecs"
    }
  ]
}

module "slb_listener" {
  source = "../../modules/slb_listener"

  load_balancer_id = module.slb_instance.id
  frontend_port    = 80
  backend_port     = 80
  protocol         = "http"
  server_group_id  = module.slb_vserver_group.id
}
```

### Complete Setup with New ECS Instances

```hcl
# Create VPC infrastructure
resource "alibabacloudstack_vpc_vpc" "default" {
  vpc_name   = "test-vpc"
  cidr_block = "172.16.0.0/16"
}

resource "alibabacloudstack_vpc_vswitch" "default" {
  name       = "test-vswitch"
  vpc_id     = alibabacloudstack_vpc_vpc.default.id
  cidr_block = "172.16.0.0/24"
  zone_id    = "cn-hangzhou-a"
}

# Create ECS instances
resource "alibabacloudstack_ecs_instance" "web" {
  count             = 2
  image_id          = "ubuntu_18_04_x64_20G_alibase_20200618.vhd"
  instance_type     = "ecs.n4.small"
  vswitch_id        = alibabacloudstack_vpc_vswitch.default.id
  security_groups   = [alibabacloudstack_ecs_securitygroup.default.id]
  instance_name     = "web-server-${count.index + 1}"
}

# Create SLB
module "slb_instance" {
  source = "../../modules/slb_instance"

  name          = "web-tier-slb"
  address_type  = "intranet"
  vswitch_id    = alibabacloudstack_vpc_vswitch.default.id
  specification = "slb.s2.small"
}

# Create VServer Group
module "slb_vserver_group" {
  source = "../../modules/slb_vserver_group"

  load_balancer_id = module.slb_instance.id
  name             = "web-servers"

  servers = [
    {
      server_ids = alibabacloudstack_ecs_instance.web[*].id
      port       = 80
      weight     = 100
      type       = "ecs"
    }
  ]
}

# Create Listener
module "slb_listener" {
  source = "../../modules/slb_listener"

  load_balancer_id = module.slb_instance.id
  frontend_port    = 80
  backend_port     = 80
  protocol         = "http"
  server_group_id  = module.slb_vserver_group.id
  
  health_check = "on"
  health_check_type = "http"
  health_check_uri = "/health"
}
```

## Environment Dependencies

### Terraform Core

| Name      | Version  |
|-----------|----------|
| Terraform | >= 1.5.6 |

### Provider

| Name              | Version                |
|-------------------|------------------------|
| alibabacloudstack | >= 3.18.25, < 3.19.0   |

## Variables

| Name               | Description                           | Type   | Default | Required |
|--------------------|---------------------------------------|--------|---------|----------|
| `vswitch_id`       | The ID of the VSwitch                 | string | -       | Yes      |
| `server_ids`       | List of ECS instance IDs              | list   | -       | Yes      |
| `specification`    | The specification of the SLB instance | string | slb.s2.small | No |

## Outputs

| Name               | Description                           |
|--------------------|---------------------------------------|
| `slb_id`           | The ID of the created SLB             |
| `slb_address`      | The address of the SLB                |
| `vserver_group_id` | The ID of the VServer Group           |

## Running the Example

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Plan the deployment:
   ```bash
   terraform plan
   ```

3. Apply the configuration:
   ```bash
   terraform apply
   ```

4. Destroy the resources (when finished):
   ```bash
   terraform destroy
   ```

## Notes

- Backend servers (ECS instances) must be in the same VPC as the SLB.
- The virtual server group must be created before the listener that references it.
- Server weights determine traffic distribution among backend servers.
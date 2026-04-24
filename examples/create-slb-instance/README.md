# Create SLB Instance Example

This example demonstrates how to create a basic SLB (Server Load Balancer) instance on Alibaba Cloud Stack using the `slb_instance` submodule.

## Overview

This example creates:
- A VPC and VSwitch (if not existing)
- An intranet SLB instance with specified specification
- Tags for resource organization

## Usage

### Basic Usage

```hcl
module "slb_instance" {
  source = "../../modules/slb_instance"

  name          = "my-slb-instance"
  address_type  = "intranet"
  vswitch_id    = "vsw-xxxxxxxx"
  specification = "slb.s1.small"

  tags = {
    Environment = "Test"
    CreatedBy   = "Terraform"
  }
}
```

### With New VPC

```hcl
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

module "slb_instance" {
  source = "../../modules/slb_instance"

  name          = "my-slb-instance"
  address_type  = "intranet"
  vswitch_id    = alibabacloudstack_vpc_vswitch.default.id
  specification = "slb.s2.small"

  tags = {
    Environment = "Production"
    Project     = "Demo"
  }
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

| Name          | Description                              | Type   | Default | Required |
|---------------|------------------------------------------|--------|---------|----------|
| `name`        | The name of the SLB instance             | string | -       | Yes      |
| `vswitch_id`  | The ID of the VSwitch (for intranet SLB) | string | -       | Yes      |
| `specification` | The specification of the SLB instance  | string | `slb.s1.small` | No |

## Outputs

| Name       | Description                    |
|------------|--------------------------------|
| `slb_id`   | The ID of the created SLB      |
| `address`  | The IP address of the SLB      |

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

- This example creates only the SLB instance without any listeners or backend servers.
- For a complete setup with listeners and backend servers, see the other examples in the parent directory.
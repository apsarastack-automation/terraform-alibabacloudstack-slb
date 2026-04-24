# Alibaba Cloud SLB Instance Terraform Module

This module creates and manages **SLB (Server Load Balancer) instances** on Alibaba Cloud Stack, supporting flexible network configuration, specification selection, and tagging capabilities.

> ✅ **Core Capability**: Supports creating SLB instances with customizable network types (internet/intranet), specifications, and VSwitch bindings.

## Features

- ✅ **Flexible Network Configuration**  
  - Supports both internet-facing and intranet SLB instances
  - VPC integration via VSwitch binding
  - Classic network support (where applicable)

- ✅ **Specification Management**  
  - Multiple performance tiers: `slb.s1.small`, `slb.s2.small`, `slb.s2.medium`, etc.
  - Shared-performance instances (default, no specification)

- ✅ **Resource Tagging**  
  - Support for Alibaba Cloud resource tags
  - Environment and purpose labeling

- ✅ **Comprehensive Output**  
  - Uniformly outputs SLB ID, name, IP address, network type, and associated VSwitch

> ⚠️ **Note**: This module **does NOT manage listeners, backend servers, or server groups**. Use dedicated submodules (`slb_listener`, `slb_backend_server`, `slb_vserver_group`) for these features.

## Usage

### Scenario 1: Create an Intranet SLB in VPC (Recommended for Internal Services)

```hcl
module "slb_instance" {
  source = "./terraform-alibabacloudstack-slb-instance"

  name          = "internal-api-slb"
  address_type  = "intranet"
  vswitch_id    = alibabacloudstack_vpc_vswitch.default.id
  specification = "slb.s2.small"

  tags = {
    Environment = "Production"
    Team        = "Platform"
  }
}
```

### Scenario 2: Create an Internet-Facing SLB (For Public Services)

```hcl
module "slb_instance" {
  source = "./terraform-alibabacloudstack-slb-instance"

  name          = "public-web-slb"
  address_type  = "internet"
  specification = "slb.s3.medium"

  tags = {
    Environment = "Production"
    Exposure    = "Public"
  }
}
```

### Scenario 3: Create a Shared-Performance SLB (Cost-Effective)

```hcl
module "slb_instance" {
  source = "./terraform-alibabacloudstack-slb-instance"

  name         = "dev-test-slb"
  address_type = "intranet"
  vswitch_id   = alibabacloudstack_vpc_vswitch.default.id
  # No specification = shared-performance instance

  tags = {
    Environment = "Development"
  }
}
```

## Environment Dependencies

### Terraform Core

| Name      | Version |
|-----------|---------|
| Terraform | >= 1.5.6 |

### Provider

| Name              | Version                |
|-------------------|------------------------|
| alibabacloudstack | >= 3.18.25, < 3.19.0   |

## Module Variables

### Input Variables

| Name              | Description                                                                 | Type         | Default      | Required | Notes                                                                 |
|-------------------|-----------------------------------------------------------------------------|--------------|--------------|----------|-----------------------------------------------------------------------|
| `name`            | The name of the SLB instance                                                | `string`     | `""`         | Yes      | Must be unique within account; max 80 characters; alphanumeric and hyphens only |
| `address_type`    | The network type of the SLB instance                                        | `string`     | `"intranet"` | No       | Valid values: `"internet"`, `"intranet"`. VPC SLB must use `"intranet"` |
| `vswitch_id`      | The ID of the VSwitch to launch the SLB in                                  | `string`     | `""`         | No*      | Required for VPC SLB; ForceNew; ignored if `address_type` is `"internet"` |
| `specification`   | The specification of the SLB instance                                       | `string`     | `""`         | No       | Valid values: `"slb.s1.small"`, `"slb.s2.small"`, `"slb.s2.medium"`, `"slb.s3.small"`, `"slb.s3.medium"`, `"slb.s3.large"`, `"slb.s4.large"`. Empty = shared-performance |
| `network_type`    | The network type of the SLB instance                                        | `string`     | `"vpc"`      | No       | Valid values: `"classic"`, `"vpc"`. Default is `vpc` |
| `tags`            | A mapping of tags to assign to the resource                                 | `map(string)`| `{}`         | No       | -                                                                     |

> 💡 **Key Constraints**:
> - `name` must be unique within your Alibaba Cloud Stack account
> - `vswitch_id` is required when creating a VPC SLB (`network_type = "vpc"`)
> - `address_type` cannot be changed after creation (ForceNew)
> - Changing `specification` may cause brief connection interruption

### Output Variables

| Name              | Description                                           |
|-------------------|-------------------------------------------------------|
| `id`              | The ID of the load balancer                           |
| `name`            | The name of the load balancer                         |
| `address`         | The IP address of the load balancer                   |
| `address_type`    | The address type of the load balancer                 |
| `specification`   | The specification of the load balancer                |
| `vswitch_id`      | The ID of the VSwitch associated with the load balancer |
| `network_type`    | The network type of the load balancer                 |

## Examples

For more typical usage patterns, refer to the `examples/` directory in the parent module:
- `create-slb-instance`: Demonstrates creating SLB instances with different configurations

## Important Notes

- 🚫 **No listener management**: This module only creates the SLB instance. Configure listeners using the `slb_listener` submodule.
- 🚫 **No backend attachment**: Backend servers must be attached separately using `slb_backend_server` or `slb_vserver_group` submodules.
- 🌐 **Address allocation**: Internet SLBs receive automatic public IP allocation. Intranet SLBs use private IPs from the VSwitch CIDR.
- ⚠️ **Specification limits**: Each specification has different performance characteristics. Refer to Alibaba Cloud documentation for details.
- 🔒 **Security groups**: SLB instances do not use security groups directly. Access control is managed via listeners (ACLs) or backend server security groups.
- 📍 **Region affinity**: SLB instances are region-specific and cannot span regions.
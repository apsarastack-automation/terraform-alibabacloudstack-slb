=====
# Alibaba Cloud SLB VServer Group Terraform Module

This module creates and manages **SLB (Server Load Balancer) Virtual Server Groups** on Alibaba Cloud Stack, allowing flexible organization of backend servers into logical groups for traffic distribution.

> ✅ **Core Capability**: Supports creating virtual server groups with multiple backend servers (ECS instances or ENIs) and associating them with SLB listeners.

## Features

- ✅ **Flexible Server Organization**  
  - Group multiple backend servers logically
  - Support for both ECS instances and ENIs
  - Configurable port and weight for each server

- ✅ **Multi-Server Support**  
  - Add multiple servers to a single group
  - Different ports and weights per server entry
  - Batch server management

- ✅ **Listener Integration**  
  - Bind virtual server groups to listeners
  - Flexible traffic routing based on URL/domain (with rules)

- ✅ **Comprehensive Output**  
  - Outputs group ID, name, associated SLB, and server list

> ⚠️ **Note**: This module **requires an existing SLB instance**. The SLB instance must be created before using this module.

## Usage

### Scenario 1: Create VServer Group with ECS Instances

```hcl
module "slb_vserver_group" {
  source = "./terraform-alibabacloudstack-slb-vserver-group"

  load_balancer_id = module.slb_instance.id
  name             = "web-tier-servers"

  servers = [
    {
      server_ids = [alibabacloudstack_ecs_instance.web1.id]
      port       = 80
      weight     = 100
      type       = "ecs"
    },
    {
      server_ids = [alibabacloudstack_ecs_instance.web2.id]
      port       = 80
      weight     = 100
      type       = "ecs"
    }
  ]
}
```

### Scenario 2: Create VServer Group with Multiple Ports

```hcl
module "slb_vserver_group" {
  source = "./terraform-alibabacloudstack-slb-vserver-group"

  load_balancer_id = module.slb_instance.id
  name             = "app-tier-mixed"

  servers = [
    {
      server_ids = [alibabacloudstack_ecs_instance.app1.id, alibabacloudstack_ecs_instance.app2.id]
      port       = 8080
      weight     = 50
      type       = "ecs"
    },
    {
      server_ids = [alibabacloudstack_ecs_instance.app1.id, alibabacloudstack_ecs_instance.app2.id]
      port       = 9090
      weight     = 50
      type       = "ecs"
    }
  ]
}
```

### Scenario 3: Create VServer Group with ENIs

```hcl
module "slb_vserver_group" {
  source = "./terraform-alibabacloudstack-slb-vserver-group"

  load_balancer_id = module.slb_instance.id
  name             = "eni-backend-group"

  servers = [
    {
      server_ids = [alibabacloudstack_network_interface.eni1.id]
      port       = 80
      weight     = 100
      type       = "eni"
    }
  ]
}
```

### Scenario 4: Use with Listener

```hcl
module "slb_vserver_group" {
  source = "./terraform-alibabacloudstack-slb-vserver-group"

  load_balancer_id = module.slb_instance.id
  name             = "api-servers"

  servers = [
    {
      server_ids = [alibabacloudstack_ecs_instance.api1.id, alibabacloudstack_ecs_instance.api2.id]
      port       = 8080
      weight     = 100
      type       = "ecs"
    }
  ]
}

module "slb_listener" {
  source = "./terraform-alibabacloudstack-slb-listener"

  load_balancer_id = module.slb_instance.id
  frontend_port    = 80
  backend_port     = 8080
  protocol         = "http"
  server_group_id  = module.slb_vserver_group.id
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

| Name                       | Description                                                                 | Type           | Default | Required | Notes                                                                 |
|----------------------------|-----------------------------------------------------------------------------|----------------|---------|----------|----------------------------------------------------|
| `load_balancer_id`         | The ID of the SLB instance                                                  | `string`       | -       | Yes      | Must be an existing SLB instance ID; ForceNew        |
| `name`                     | Name of the virtual server group                                            | `string`       | `""`    | No       | Human-readable identifier                            |
| `vserver_group_name`       | Alternative name field for the VServer Group                                | `string`       | `""`    | No       | Use either `name` or `vserver_group_name`            |
| `servers`                  | A list of backend servers to be added                                       | `list(object)` | `[]`    | No       | Max 20 servers per resource; see server object below |
| `delete_protection_validation` | Checking DeleteProtection of SLB instance before deleting                 | `bool`         | `false` | No       | If true, prevents deletion when DeleteProtection is enabled |

#### Server Object

| Name         | Description                              | Type           | Default | Required |
|--------------|------------------------------------------|----------------|---------|----------|
| `server_ids` | A list of backend server IDs             | `list(string)` | -       | Yes      |
| `port`       | The port used by the backend server      | `number`       | -       | Yes      |
| `weight`     | Weight of the backend server             | `number`       | `100`   | No       |
| `type`       | Type of the backend server               | `string`       | `"ecs"` | No       |

> 💡 **Key Constraints**:
> - Maximum 20 servers can be added in one resource
> - `server_ids` can contain multiple IDs for batch operations
> - `type` valid values: `"ecs"` (ECS instance), `"eni"` (Elastic Network Interface)
> - `weight` valid range: [0-100]
> - `port` valid range: [1-65535]

### Output Variables

| Name               | Description                                           |
|--------------------|-------------------------------------------------------|
| `id`               | The ID of the VServer Group                           |
| `load_balancer_id` | The Load Balancer ID associated with the group        |
| `name`             | The name of the VServer Group                         |
| `vserver_group_name` | The name of the VServer Group (alias)               |
| `servers`          | List of servers in the group                          |

## Examples

For more typical usage patterns, refer to the `examples/` directory in the parent module:
- `create-slb-with-vserver-group`: Demonstrates creating SLB with virtual server groups

## Important Notes

- 🔗 **SLB dependency**: This module requires an existing SLB instance. Ensure the SLB is created before applying this module.
- 📝 **Naming**: Use either `name` or `vserver_group_name` to specify the group name. Both refer to the same attribute.
- ⚖️ **Weight distribution**: Server weights determine traffic distribution. Higher weight = more traffic.
- 🔄 **Server updates**: Modifying the `servers` list will update the group in-place. Adding/removing servers is supported.
- 🛡️ **Delete protection**: Enable `delete_protection_validation` to prevent accidental deletion of protected SLBs.
- 🖥️ **Server types**: Choose `"ecs"` for ECS instances or `"eni"` for Elastic Network Interfaces.
- 📊 **Multi-port support**: Create multiple server entries with different ports to support multi-port applications.
- 🔒 **Security**: Backend servers must have appropriate security group rules to allow traffic from the SLB.
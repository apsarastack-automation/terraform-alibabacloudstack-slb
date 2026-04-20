# Alibaba Cloud SLB Terraform Root Module

This root module is designed to create and manage **SLB (Server Load Balancer)** resources on Alibaba Cloud Stack. By encapsulating the underlying SLB submodules, it provides a clean, secure, and declarative interface aligned with Infrastructure-as-Code (IaC) best practices. Users need not interact directly with submodule paths or handle reuse logic—common tasks such as creating a load balancer, configuring listeners, and attaching backend servers can be accomplished by configuring only core parameters.

> ✅ **Clear Scope**: This module serves as a **top-level abstraction layer**, hiding low-level submodule details and focusing on "out-of-the-box" load balancer creation and basic configuration capabilities. All advanced features (e.g., virtual server groups, master-slave server groups, access control lists, SSL certificates) are supported via pass-through parameters—but variables *not invoked* in the root module remain **unexposed**, even if they exist in the submodule.

## Features

- ✅ **One-click creation of SLB instances**  
  Supports customizing load balancer name, network type (internet/intranet), specification, VSwitch binding, and tags.

- ✅ **Flexible listener configuration**  
  Supports HTTP, HTTPS, TCP, and UDP protocols with configurable frontend/backend ports, scheduling algorithms (wrr/rr/wlc), session persistence, and health checks.

- ✅ **Backend server management**  
  Attach ECS instances or ENIs as backend servers with configurable weights and ports.

- ✅ **Virtual Server Group support**  
  Organize backend servers into logical groups for flexible traffic distribution.

- ✅ **Enterprise-grade security**  
  Support for access control lists (ACLs), SSL/TLS certificates, and HTTPS redirect.

- ⚠️ **Advanced configurations via submodules**  
  Complex features like master-slave server groups, forwarding rules, and domain extensions are available through dedicated submodules.

## Usage

### Basic Usage: Create an intranet SLB with HTTP listener

```hcl
module "slb" {
  source = "./."

  name          = "my-app-slb"
  address_type  = "intranet"
  vswitch_id    = "vsw-xxxxxxxx"
  specification = "slb.s1.small"

  # Listener configuration
  listeners = [
    {
      frontend_port = 80
      backend_port  = 8080
      protocol      = "http"
      bandwidth     = 10
      scheduler     = "wrr"
    }
  ]
}
```

### Advanced Usage: Create HTTPS SLB with SSL certificate

```hcl
module "slb" {
  source = "./."

  name          = "secure-app-slb"
  address_type  = "internet"
  specification = "slb.s2.small"

  # SSL certificate
  server_certificate = file("${path.module}/cert.pem")
  private_key        = file("${path.module}/key.pem")

  # HTTPS listener
  listeners = [
    {
      frontend_port       = 443
      backend_port        = 80
      protocol            = "https"
      bandwidth           = 100
      scheduler           = "wrr"
      sticky_session      = "on"
      sticky_session_type = "insert"
      cookie_timeout      = 3600
      health_check        = "on"
      health_check_type   = "http"
      health_check_uri    = "/health"
    }
  ]
}
```

### Usage with Backend Servers

```hcl
module "slb" {
  source = "./."

  name          = "web-tier-slb"
  address_type  = "intranet"
  vswitch_id    = alibabacloudstack_vpc_vswitch.default.id
  specification = "slb.s2.medium"

  listeners = [
    {
      frontend_port = 80
      backend_port  = 80
      protocol      = "http"
      bandwidth     = 50
    }
  ]

  backend_servers = [
    {
      server_id = alibabacloudstack_ecs_instance.web1.id
      port      = 80
      weight    = 100
    },
    {
      server_id = alibabacloudstack_ecs_instance.web2.id
      port      = 80
      weight    = 100
    }
  ]
}
```

## Environment Dependencies

### Terraform Core

| Name      | Version     |
|-----------|-------------|
| Terraform | >= 1.5.6    |

### Provider

| Name              | Version                 |
|-------------------|-------------------------|
| alibabacloudstack | >= 3.18.25, < 3.19.0    |

## Module Variables

### Input Variables

| Name                   | Description                                                                     | Type           | Default       | Required | Notes                                                                 |
|------------------------|---------------------------------------------------------------------------------|----------------|---------------|----------|-----------------------------------------------------------------------|
| `name`                 | The name of the SLB instance                                                    | `string`       | `""`          | Yes      | Must be unique within your account; max 80 characters                 |
| `address_type`         | The network type of the SLB instance                                            | `string`       | `"intranet"`  | No       | Valid values: `"internet"`, `"intranet"`                            |
| `vswitch_id`           | The ID of the VSwitch to launch the SLB in                                      | `string`       | `""`          | No*      | Required for VPC SLB; ignored if `address_type` is `"internet"`       |
| `specification`        | The specification of the SLB instance                                           | `string`       | `""`          | No       | Valid values: `slb.s1.small`, `slb.s2.small`, `slb.s2.medium`, etc.   |
| `network_type`         | The network type of the SLB instance                                            | `string`       | `"vpc"`       | No       | Valid values: `"classic"`, `"vpc"`                                  |
| `tags`                 | A mapping of tags to assign to the resource                                     | `map(string)`  | `{}`          | No       | -                                                                     |
| `listeners`            | List of listener configurations                                                 | `list(object)` | `[]`          | No       | See listener configuration object below                               |
| `backend_servers`      | List of backend servers to attach                                               | `list(object)` | `[]`          | No       | Each object requires `server_id`, `port`, and `weight`                |
| `server_certificate`   | The public key certificate for HTTPS listeners                                  | `string`       | `""`          | No       | Required when creating HTTPS listeners                                |
| `private_key`          | The private key corresponding to the certificate                                | `string`       | `""`          | No       | Required when creating HTTPS listeners                                |

#### Listener Configuration Object

| Name                      | Description                                         | Type     | Default  | Required |
|---------------------------|-----------------------------------------------------|----------|----------|----------|
| `frontend_port`           | Port used by the SLB instance frontend              | `number` | -        | Yes      |
| `backend_port`            | Port used by the SLB instance backend               | `number` | -        | Yes      |
| `protocol`                | The protocol to listen on                           | `string` | `"http"` | No       |
| `bandwidth`               | Bandwidth peak of Listener (Mbps)                   | `number` | `-1`     | No       |
| `scheduler`               | Scheduling algorithm                                | `string` | `"wrr"`  | No       |
| `sticky_session`          | Whether to enable session persistence               | `string` | `"off"`  | No       |
| `sticky_session_type`     | Mode for handling the cookie                        | `string` | `""`     | No       |
| `cookie_timeout`          | Cookie timeout in seconds                           | `number` | `0`      | No       |
| `health_check`            | Whether to enable health check                      | `string` | `"off"`  | No       |
| `health_check_type`       | Type of health check                                | `string` | `"tcp"`  | No       |
| `health_check_uri`        | URI used for health check                           | `string` | `""`     | No       |
| `health_check_domain`     | Domain name used for health check                   | `string` | `""`     | No       |

### Output Variables

| Name              | Description                                         |
|-------------------|-----------------------------------------------------|
| `slb_id`          | The ID of the load balancer                         |
| `slb_name`        | The name of the load balancer                       |
| `address`         | The IP address of the load balancer                 |
| `address_type`    | The address type of the load balancer               |
| `specification`   | The specification of the load balancer              |
| `vswitch_id`      | The ID of the VSwitch associated with the load balancer |
| `listener_ids`    | List of listener IDs created                        |

## Examples

For more complete usage examples, see the [`examples/`](./examples) directory:
- `create-slb-instance`: Creates a basic SLB instance
- `create-slb-listener`: Creates an SLB with HTTP/HTTPS listeners
- `create-slb-with-backend-servers`: Creates an SLB and attaches backend servers
- `create-slb-with-vserver-group`: Creates an SLB with virtual server groups

## Important Notes

- 🚫 **No existing resource reuse**: This module **supports only new SLB creation**, and cannot reference or manage pre-existing SLB instances. To reuse an existing SLB, use the submodules directly.
- 🔐 **Certificate management**: When using HTTPS listeners, ensure the `server_certificate` and `private_key` are properly formatted PEM strings.
- 🌐 **Network configuration**: For internet-facing SLBs (`address_type = "internet"`), the system allocates a public IP automatically. For intranet SLBs, a `vswitch_id` is required.
- ⚠️ **Specification limits**: Different specifications have different performance limits (max connections, CPS, QPS). Choose according to your workload.
- 🏥 **Health checks**: TCP and UDP listeners have health checks always enabled. HTTP/HTTPS listeners support configurable health checks.
- 📦 **Idempotent operations**: Backend server attachments are managed via the module. Repeated `apply` with identical configurations will not create duplicates.
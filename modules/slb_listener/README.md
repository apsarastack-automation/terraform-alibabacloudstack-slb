# Alibaba Cloud SLB Listener Terraform Module

This module creates and manages **SLB (Server Load Balancer) listeners** on Alibaba Cloud Stack, supporting HTTP, HTTPS, TCP, and UDP protocols with comprehensive health check, session persistence, and SSL/TLS configuration.

> ✅ **Core Capability**: Supports creating listeners with flexible protocol selection, port configuration, scheduling algorithms, and advanced features like session persistence and health checks.

## Features

- ✅ **Multi-Protocol Support**  
  - HTTP/HTTPS for web applications
  - TCP for generic layer-4 traffic
  - UDP for connectionless protocols

- ✅ **Advanced Scheduling**  
  - Weighted Round Robin (wrr)
  - Round Robin (rr)
  - Weighted Least Connections (wlc)

- ✅ **Session Persistence**  
  - Cookie-based session stickiness
  - Insert and server cookie modes
  - Configurable timeout

- ✅ **Health Checks**  
  - TCP and HTTP health check types
  - Customizable intervals, thresholds, and timeouts
  - Domain and URI configuration for HTTP checks

- ✅ **SSL/TLS Support**  
  - Server certificate binding
  - CA certificate support
  - TLS cipher policy configuration
  - HTTP/2 enablement

- ✅ **Access Control**  
  - ACL binding for whitelist/blacklist
  - X-Forwarded-For header configuration

> ⚠️ **Note**: This module **requires an existing SLB instance**. Create the SLB first using the `slb_instance` module.

## Usage

### Scenario 1: Create HTTP Listener with Basic Configuration

```hcl
module "slb_listener" {
  source = "./terraform-alibabacloudstack-slb-listener"

  load_balancer_id = module.slb_instance.id
  frontend_port    = 80
  backend_port     = 8080
  protocol         = "http"
  bandwidth        = 10
  scheduler        = "wrr"
}
```

### Scenario 2: Create HTTPS Listener with SSL Certificate

```hcl
module "slb_listener" {
  source = "./terraform-alibabacloudstack-slb-listener"

  load_balancer_id       = module.slb_instance.id
  frontend_port          = 443
  backend_port           = 80
  protocol               = "https"
  bandwidth              = 100
  scheduler              = "wrr"
  server_certificate_id  = alibabacloudstack_slb_server_certificate.default.id
  
  sticky_session      = "on"
  sticky_session_type = "insert"
  cookie_timeout      = 3600
  
  health_check      = "on"
  health_check_type = "http"
  health_check_uri  = "/health"
}
```

### Scenario 3: Create TCP Listener with Health Check

```hcl
module "slb_listener" {
  source = "./terraform-alibabacloudstack-slb-listener"

  load_balancer_id = module.slb_instance.id
  frontend_port    = 3306
  backend_port     = 3306
  protocol         = "tcp"
  bandwidth        = -1
  scheduler        = "wlc"
  
  persistence_timeout = 3600
  established_timeout = 600
}
```

### Scenario 4: Create Listener with ACL

```hcl
module "slb_listener" {
  source = "./terraform-alibabacloudstack-slb-listener"

  load_balancer_id = module.slb_instance.id
  frontend_port    = 80
  backend_port     = 80
  protocol         = "http"
  bandwidth        = 50
  
  acl_status = "on"
  acl_type   = "white"
  acl_id     = alibabacloudstack_slb_acl.default.id
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

| Name                        | Description                                                                 | Type         | Default    | Required | Notes                                                                 |
|-----------------------------|-----------------------------------------------------------------------------|--------------|------------|----------|-------------------------------------------------------|
| `load_balancer_id`          | ID of the load balancing instance                                           | `string`     | -          | Yes      | Must be an existing SLB instance ID                   |
| `frontend_port`             | Port used by the SLB instance frontend                                      | `number`     | -          | Yes      | Valid range: [1-65535]; ForceNew                      |
| `backend_port`              | Port used by the SLB instance backend                                       | `number`     | -          | Yes      | Valid range: [1-65535]; ForceNew                      |
| `protocol`                  | The protocol to listen on                                                   | `string`     | `"http"`   | No       | Valid values: `"http"`, `"https"`, `"tcp"`, `"udp"` |
| `bandwidth`                 | Bandwidth peak of Listener (Mbps)                                           | `number`     | `-1`       | No       | `-1` means unlimited; valid range: [-1, 1-5000]       |
| `scheduler`                 | Scheduling algorithm                                                        | `string`     | `"wrr"`    | No       | Valid values: `"wrr"`, `"rr"`, `"wlc"`              |
| `server_group_id`           | The bound server group ID                                                   | `string`     | `""`       | No       | Virtual server group ID                               |
| `master_slave_server_group_id` | The ID of the primary/secondary server group                              | `string`     | `""`       | No       | Cannot set both `server_group_id` and this            |
| `sticky_session`            | Whether to enable session persistence                                       | `string`     | `"off"`    | No       | Valid values: `"on"`, `"off"`                       |
| `sticky_session_type`       | Mode for handling the cookie                                                | `string`     | `""`       | No       | Required if `sticky_session` is `"on"`; values: `"insert"`, `"server"` |
| `cookie_timeout`            | Cookie timeout in seconds                                                   | `number`     | `0`        | No       | Valid range: [1-86400]; required for insert mode      |
| `cookie`                    | The cookie configured on the server                                         | `string`     | `""`       | No       | Required for server mode                              |
| `persistence_timeout`       | Timeout of connection persistence (TCP/UDP)                                 | `number`     | `0`        | No       | Valid range: [0-3600] seconds                         |
| `health_check`              | Whether to enable health check                                              | `string`     | `"off"`    | No       | TCP/UDP always on; valid values: `"on"`, `"off"`    |
| `health_check_type`         | Type of health check                                                        | `string`     | `"tcp"`    | No       | Valid values: `"tcp"`, `"http"`                     |
| `health_check_domain`       | Domain name used for health check                                           | `string`     | `""`       | No       | Required for HTTP health check on TCP listener        |
| `health_check_uri`          | URI used for health check                                                   | `string`     | `""`       | No       | Must start with `/`; length 1-80                      |
| `health_check_connect_port` | Port used for health check                                                  | `number`     | `0`        | No       | Default uses backend port; range: [1-65535]           |
| `healthy_threshold`         | Threshold for health check success                                          | `number`     | `3`        | No       | Valid range: [1-10]                                   |
| `unhealthy_threshold`       | Threshold for health check failure                                          | `number`     | `3`        | No       | Valid range: [1-10]                                   |
| `health_check_timeout`      | Maximum timeout of each health check response                               | `number`     | `5`        | No       | Valid range: [1-300] seconds                          |
| `health_check_interval`     | Time interval of health checks                                              | `number`     | `2`        | No       | Valid range: [1-50] seconds                           |
| `health_check_http_code`    | Regular health check HTTP status code                                       | `string`     | `"http_2xx"` | No     | Values: `http_2xx`, `http_3xx`, `http_4xx`, `http_5xx` |
| `server_certificate_id`     | SLB Server certificate ID                                                   | `string`     | `""`       | No       | Required for HTTPS protocol                           |
| `ca_certificate_id`         | The ID of the CA certificate                                                | `string`     | `""`       | No       | For HTTPS mutual authentication                       |
| `acl_status`                | Whether to enable access control                                            | `string`     | `"off"`    | No       | Valid values: `"on"`, `"off"`                       |
| `acl_type`                  | The type of the network ACL                                                 | `string`     | `""`       | No       | Required if `acl_status` is `"on"`; values: `"black"`, `"white"` |
| `acl_id`                    | The ID of the network ACL                                                   | `string`     | `""`       | No       | Required if `acl_status` is `"on"`                  |
| `gzip`                      | Whether to enable Gzip Compression                                          | `bool`       | `true`     | No       | HTTP/HTTPS only                                       |
| `enable_http2`              | Whether to enable HTTP/2                                                    | `string`     | `"on"`     | No       | HTTPS only; values: `"on"`, `"off"`               |
| `tls_cipher_policy`         | The TLS security policy                                                     | `string`     | `"tls_cipher_policy_1_0"` | No | See Alibaba Cloud documentation |
| `established_timeout`       | Timeout of TCP established connection idle timeout                          | `number`     | `900`      | No       | TCP only; valid range: [10-900] seconds               |

### Output Variables

| Name              | Description                                           |
|-------------------|-------------------------------------------------------|
| `id`              | The ID of the load balancer listener (format: `<load_balancer_id>:<protocol>:<frontend_port>`) |
| `description`     | The listener description                              |

## Examples

For more typical usage patterns, refer to the `examples/` directory in the parent module:
- `create-slb-listener`: Demonstrates creating various types of listeners

## Important Notes

- 🔗 **SLB dependency**: This module requires an existing SLB instance. Ensure the SLB is created before applying this module.
- 🔄 **ForceNew fields**: `frontend_port`, `backend_port`, and `protocol` cannot be changed after creation. To modify, destroy and recreate the listener.
- 🏥 **TCP/UDP health checks**: Health checks are always enabled for TCP and UDP listeners and cannot be disabled.
- 🔒 **HTTPS requirements**: HTTPS listeners require a valid `server_certificate_id`. Create certificates using the `slb_server_certificate` resource.
- ⚖️ **Mutual exclusion**: `server_group_id` and `master_slave_server_group_id` cannot both be set simultaneously.
- 📊 **Bandwidth**: Set to `-1` for unlimited bandwidth (recommended for pay-by-traffic instances).
- 🍪 **Session persistence**: When enabled, choose between `insert` (SLB manages cookie) or `server` (backend manages cookie) modes.
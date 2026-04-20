# SLB Resource Relationship

This document describes the resource relationships within the `terraform-alibabacloudstack-slb` module, following the structure and conventions established in the Alibaba Cloud Stack Terraform documentation.

## Resource Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│                     VPC / VSwitch                            │
│                  (Network Infrastructure)                    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   SLB Instance                               │
│              (alibabacloudstack_slb_loadbalancer)            │
│  - Network Type: Internet / Intranet                         │
│  - Specification: slb.s1.small ~ slb.s4.large                │
│  - VSwitch Binding (for VPC SLB)                             │
└─────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼───────────────┐
              │               │               │
              ▼               ▼               ▼
┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐
│   SLB Listener   │ │   SLB Listener   │ │   SLB Listener   │
│    (HTTP/HTTPS)  │ │     (TCP/UDP)    │ │     (Custom)     │
│ - Frontend Port  │ │ - Layer 4        │ │ - Advanced       │
│ - Backend Port   │ │ - High Perf.     │ │ - Rules          │
│ - SSL/TLS        │ │ - Persistence    │ │ - Domains        │
│ - Health Check   │ │ - Health Check   │ │ - ACLs           │
└──────────────────┘ └──────────────────┘ └──────────────────┘
              │
              │ (optional binding)
              ▼
┌─────────────────────────────────────────────────────────────┐
│              Virtual Server Group                             │
│         (alibabacloudstack_slb_vservergroup)                 │
│  - Multiple Backend Servers                                  │
│  - Configurable Weights                                      │
│  - ECS Instances or ENIs                                     │
└─────────────────────────────────────────────────────────────┘
              │
              │ contains
              ▼
┌─────────────────────────────────────────────────────────────┐
│              Backend Servers                                 │
│         (ECS Instances / ENIs)                               │
│  - Server ID                                                 │
│  - Port Configuration                                        │
│  - Weight Distribution                                       │
└─────────────────────────────────────────────────────────────┘
```

## Core Resources

### 1. SLB Instance (`slb_instance`)

**Resource Type**: `alibabacloudstack_slb_loadbalancer`

**Dependencies**:
- VPC/VSwitch (for intranet SLB)
- Region configuration

**Key Attributes**:
- `id`: The SLB instance ID
- `address`: IP address (auto-assigned)
- `address_type`: Network type (internet/intranet)
- `specification`: Performance tier
- `vswitch_id`: Associated VSwitch

**Usage**: Foundation resource that must be created first before any listeners or server groups.

---

### 2. SLB Listener (`slb_listener`)

**Resource Type**: `alibabacloudstack_slb_listener`

**Dependencies**:
- SLB Instance (required)
- Server Certificate (for HTTPS)
- Access Control List (optional)

**Key Attributes**:
- `id`: Listener ID (format: `<slb_id>:<protocol>:<frontend_port>`)
- `load_balancer_id`: Parent SLB ID
- `frontend_port`, `backend_port`: Port mapping
- `protocol`: HTTP/HTTPS/TCP/UDP
- `server_group_id`: Bound VServer group (optional)

**Protocols Supported**:
- **HTTP/HTTPS**: Layer 7 load balancing with advanced features
- **TCP/UDP**: Layer 4 load balancing for high performance

---

### 3. Virtual Server Group (`slb_vserver_group`)

**Resource Type**: `alibabacloudstack_slb_vservergroup`

**Dependencies**:
- SLB Instance (required)
- Backend servers (ECS instances or ENIs)

**Key Attributes**:
- `id`: VServer group ID
- `load_balancer_id`: Associated SLB ID
- `servers`: List of backend server configurations

**Server Configuration**:
```hcl
servers = [
  {
    server_ids = ["i-xxx", "i-yyy"]
    port       = 80
    weight     = 100
    type       = "ecs"  # or "eni"
  }
]
```

---

## Supporting Resources

### SSL/TLS Certificates

**Resource Types**:
- `alibabacloudstack_slb_server_certificate` - Server certificates
- `alibabacloudstack_slb_cacertificate` - CA certificates

**Used by**: HTTPS listeners for TLS termination

### Access Control Lists

**Resource Type**: `alibabacloudstack_slb_accesscontrollist`

**Used by**: Listeners for IP-based access control (whitelist/blacklist)

### Master-Slave Server Groups

**Resource Type**: `alibabacloudstack_slb_masterslaveservergroup`

**Use Case**: Active-passive failover configurations

### Forwarding Rules

**Resource Type**: `alibabacloudstack_slb_rule`

**Use Case**: URL/domain-based routing to different VServer groups

---

## Module Structure

Following the `terraform-alibabacloudstack-oss` pattern, this project is organized as:

```
terraform-alibabacloudstack-slb/
├── README.md                          # Root module documentation
├── README_zh-Hans.md                  # Chinese documentation
├── modules/
│   ├── slb_instance/                  # SLB instance management
│   │   ├── README.md
│   │   └── README_zh-Hans.md
│   ├── slb_listener/                  # Listener configuration
│   │   ├── README.md
│   │   └── README_zh-Hans.md
│   └── slb_vserver_group/             # Virtual server groups
│       ├── README.md
│       └── README_zh-Hans.md
└── examples/
    ├── create-slb-instance/           # Basic SLB creation
    │   ├── README.md
    │   └── README_zh-Hans.md
    ├── create-slb-listener/           # Listener configuration
    │   ├── README.md
    │   └── README_zh-Hans.md
    └── create-slb-with-vserver-group/ # Complete setup
        ├── README.md
        └── README_zh-Hans.md
```

---

## Common Deployment Patterns

### Pattern 1: Simple Web Application

```
SLB Instance (Internet)
  └── HTTP Listener (80 -> 8080)
      └── VServer Group
          ├── ECS-1 (weight: 50)
          └── ECS-2 (weight: 50)
```

### Pattern 2: HTTPS Termination

```
SLB Instance (Internet)
  └── HTTPS Listener (443 -> 80)
      ├── Server Certificate
      └── VServer Group
          └── Backend ECS instances
```

### Pattern 3: Multi-Protocol Setup

```
SLB Instance (Intranet)
  ├── HTTP Listener (80 -> 8080)
  │   └── VServer Group (Web tier)
  └── TCP Listener (3306 -> 3306)
      └── VServer Group (Database tier)
```

### Pattern 4: Advanced Routing

```
SLB Instance (Internet)
  └── HTTPS Listener (443)
      ├── Rule: /api/* → API VServer Group
      ├── Rule: /static/* → Static VServer Group
      └── Default → Main VServer Group
```

---

## Best Practices

1. **Create Order**: Always create SLB instance → VServer groups → Listeners
2. **Health Checks**: Enable health checks for production workloads
3. **Session Persistence**: Use only when necessary (stateful applications)
4. **Security**: Implement ACLs for sensitive services
5. **Monitoring**: Configure access logs for audit and troubleshooting
6. **High Availability**: Deploy backend servers across multiple zones
7. **Specification**: Choose appropriate SLB specification based on expected load

---

## References

- [Alibaba Cloud SLB Documentation](https://www.alibabacloud.com/help/product/27544.htm)
- [Terraform Provider Documentation](https://registry.terraform.io/providers/aliyun/alibabacloudstack/latest/docs)
- Original SLB resource docs: `doc/docs/r/slb_*.html.markdown`
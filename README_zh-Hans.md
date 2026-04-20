# 阿里云 SLB Terraform 根模块

此根模块旨在在阿里云专有云（Alibaba Cloud Stack）上创建和管理 **SLB（负载均衡）** 资源。通过封装底层 SLB 子模块，它提供了一个简洁、安全且声明式的接口，符合基础设施即代码（IaC）最佳实践。用户无需直接与子模块路径交互或处理重用逻辑——只需配置核心参数，即可完成创建负载均衡器、配置监听和挂载后端服务器等常见任务。

> ✅ **清晰范围**：该模块作为**顶层抽象层**，隐藏底层子模块细节，专注于"开箱即用"的负载均衡器创建和基本配置能力。所有高级功能（如虚拟服务器组、主备服务器组、访问控制列表、SSL 证书）都通过透传参数支持——但在根模块中未调用的变量即使存在于子模块中，也保持**不暴露**。

## 功能特性

- ✅ **一键创建 SLB 实例**  
  支持自定义负载均衡器名称、网络类型（公网/内网）、规格、VSwitch 绑定和标签。

- ✅ **灵活的监听配置**  
  支持 HTTP、HTTPS、TCP 和 UDP 协议，可配置前端/后端端口、调度算法（wrr/rr/wlc）、会话保持和健康检查。

- ✅ **后端服务器管理**  
  将 ECS 实例或 ENI 作为后端服务器挂载，支持配置权重和端口。

- ✅ **虚拟服务器组支持**  
  将后端服务器组织成逻辑组，实现灵活的流量分发。

- ✅ **企业级安全**  
  支持访问控制列表（ACL）、SSL/TLS 证书和 HTTPS 重定向。

- ⚠️ **通过子模块实现高级配置**  
  主备服务器组、转发规则和域名扩展等复杂功能可通过专用子模块使用。

## 使用方法

### 基础用法：创建内网 SLB 并配置 HTTP 监听

```hcl
module "slb" {
  source = "./."

  name          = "my-app-slb"
  address_type  = "intranet"
  vswitch_id    = "vsw-xxxxxxxx"
  specification = "slb.s1.small"

  # 监听配置
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

### 高级用法：创建 HTTPS SLB 并配置 SSL 证书

```hcl
module "slb" {
  source = "./."

  name          = "secure-app-slb"
  address_type  = "internet"
  specification = "slb.s2.small"

  # SSL 证书
  server_certificate = file("${path.module}/cert.pem")
  private_key        = file("${path.module}/key.pem")

  # HTTPS 监听
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

### 带后端服务器的用法

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

## 环境依赖

### Terraform 核心

| 名称      | 版本        |
|-----------|-------------|
| Terraform | >= 1.5.6    |

### 提供商

| 名称              | 版本                    |
|-------------------|-------------------------|
| alibabacloudstack | >= 3.18.25, < 3.19.0    |

## 模块变量

### 输入变量

| 名称                   | 描述                                           | 类型           | 默认值        | 必填 | 说明                                                  |
|------------------------|------------------------------------------------|----------------|---------------|------|-------------------------------------------------------|
| `name`                 | SLB 实例名称                                   | `string`       | `""`          | 是   | 在账户内必须唯一；最多 80 个字符                      |
| `address_type`         | SLB 实例的网络类型                             | `string`       | `"intranet"`  | 否   | 有效值：`"internet"`、`"intranet"`                   |
| `vswitch_id`           | 启动 SLB 的 VSwitch ID                         | `string`       | `""`          | 否*  | VPC SLB 必填；如 `address_type` 为 `"internet"` 则忽略 |
| `specification`        | SLB 实例的规格                                 | `string`       | `""`          | 否   | 有效值：`slb.s1.small`、`slb.s2.small` 等            |
| `network_type`         | SLB 实例的网络类型                             | `string`       | `"vpc"`       | 否   | 有效值：`"classic"`、`"vpc"`                        |
| `tags`                 | 分配给资源的标签映射                           | `map(string)`  | `{}`          | 否   | -                                                     |
| `listeners`            | 监听配置列表                                   | `list(object)` | `[]`          | 否   | 详见监听配置对象                                      |
| `backend_servers`      | 要挂载的后端服务器列表                         | `list(object)` | `[]`          | 否   | 每个对象需要 `server_id`、`port` 和 `weight`          |
| `server_certificate`   | HTTPS 监听的服务器证书                         | `string`       | `""`          | 否   | 创建 HTTPS 监听时必填                                 |
| `private_key`          | 证书对应的私钥                                 | `string`       | `""`          | 否   | 创建 HTTPS 监听时必填                                 |

#### 监听配置对象

| 名称                      | 描述                           | 类型     | 默认值   | 必填 |
|---------------------------|--------------------------------|----------|----------|------|
| `frontend_port`           | SLB 实例前端使用的端口         | `number` | -        | 是   |
| `backend_port`            | SLB 实例后端使用的端口         | `number` | -        | 是   |
| `protocol`                | 监听协议                       | `string` | `"http"` | 否   |
| `bandwidth`               | 监听带宽峰值（Mbps）           | `number` | `-1`     | 否   |
| `scheduler`               | 调度算法                       | `string` | `"wrr"`  | 否   |
| `sticky_session`          | 是否开启会话保持               | `string` | `"off"`  | 否   |
| `sticky_session_type`     | 处理 Cookie 的模式             | `string` | `""`     | 否   |
| `cookie_timeout`          | Cookie 超时时间（秒）          | `number` | `0`      | 否   |
| `health_check`            | 是否开启健康检查               | `string` | `"off"`  | 否   |
| `health_check_type`       | 健康检查类型                   | `string` | `"tcp"`  | 否   |
| `health_check_uri`        | 健康检查使用的 URI             | `string` | `""`     | 否   |
| `health_check_domain`     | 健康检查使用的域名             | `string` | `""`     | 否   |

### 输出变量

| 名称              | 描述                           |
|-------------------|--------------------------------|
| `slb_id`          | 负载均衡器的 ID                |
| `slb_name`        | 负载均衡器的名称               |
| `address`         | 负载均衡器的 IP 地址           |
| `address_type`    | 负载均衡器的地址类型           |
| `specification`   | 负载均衡器的规格               |
| `vswitch_id`      | 负载均衡器关联的 VSwitch ID    |
| `listener_ids`    | 创建的监听 ID 列表             |

## 示例

更多完整的使用示例，请参阅 [`examples/`](./examples) 目录：
- `create-slb-instance`：创建基础 SLB 实例
- `create-slb-listener`：创建带 HTTP/HTTPS 监听的 SLB
- `create-slb-with-backend-servers`：创建 SLB 并挂载后端服务器
- `create-slb-with-vserver-group`：创建带虚拟服务器组的 SLB

## 重要说明

- 🚫 **不支持现有资源重用**：此模块**仅支持创建新的 SLB**，无法引用或管理已存在的 SLB 实例。要重用现有 SLB，请直接使用子模块。
- 🔐 **证书管理**：使用 HTTPS 监听时，请确保 `server_certificate` 和 `private_key` 是正确格式的 PEM 字符串。
- 🌐 **网络配置**：对于公网 SLB（`address_type = "internet"`），系统会自动分配公网 IP。对于内网 SLB，需要提供 `vswitch_id`。
- ⚠️ **规格限制**：不同规格有不同的性能限制（最大连接数、CPS、QPS）。请根据工作负载选择。
- 🏥 **健康检查**：TCP 和 UDP 监听始终启用健康检查。HTTP/HTTPS 监听支持可配置的健康检查。
- 📦 **幂等操作**：后端服务器挂载通过模块管理。使用相同配置重复执行 `apply` 不会创建重复项。
# 阿里云 SLB 监听 Terraform 模块

此模块用于在阿里云专有云（Alibaba Cloud Stack）上创建和管理 **SLB（负载均衡）监听**，支持 HTTP、HTTPS、TCP 和 UDP 协议，具备全面的健康检查、会话持久性和 SSL/TLS 配置功能。

> ✅ **核心能力**：支持创建具有灵活协议选择、端口配置、调度算法以及会话持久性和健康检查等高级功能的监听。

## 功能特性

- ✅ **多协议支持**  
  - 用于 Web 应用的 HTTP/HTTPS
  - 用于通用四层流量的 TCP
  - 用于无连接协议的 UDP

- ✅ **高级调度**  
  - 加权轮询（wrr）
  - 轮询（rr）
  - 加权最少连接（wlc）

- ✅ **会话持久性**  
  - 基于 Cookie 的会话粘性
  - Insert 和 Server Cookie 模式
  - 可配置的超时时间

- ✅ **健康检查**  
  - TCP 和 HTTP 健康检查类型
  - 可自定义间隔、阈值和超时时间
  - HTTP 检查的域名和 URI 配置

- ✅ **SSL/TLS 支持**  
  - 服务器证书绑定
  - CA 证书支持
  - TLS 加密策略配置
  - HTTP/2 启用

- ✅ **访问控制**  
  - ACL 绑定实现白名单/黑名单
  - X-Forwarded-For 头配置

> ⚠️ **注意**：此模块**需要现有的 SLB 实例**。请先使用 `slb_instance` 模块创建 SLB。

## 使用方法

### 场景 1：创建基础 HTTP 监听

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

### 场景 2：创建带 SSL 证书的 HTTPS 监听

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

### 场景 3：创建带健康检查的 TCP 监听

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

### 场景 4：创建带 ACL 的监听

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

## 环境依赖

### Terraform 核心

| 名称      | 版本     |
|-----------|----------|
| Terraform | >= 1.5.6 |

### 提供商

| 名称              | 版本                    |
|-------------------|-------------------------|
| alibabacloudstack | >= 3.18.25, < 3.19.0    |

## 模块变量

### 输入变量

| 名称                        | 描述                                           | 类型          | 默认值       | 必填 | 说明                                                  |
|-----------------------------|------------------------------------------------|---------------|--------------|------|-------------------------------------------------------|
| `load_balancer_id`          | 负载均衡实例 ID                                | `string`      | -            | 是   | 必须是现有的 SLB 实例 ID                              |
| `frontend_port`             | SLB 实例前端使用的端口                         | `number`      | -            | 是   | 有效范围：[1-65535]；ForceNew                        |
| `backend_port`              | SLB 实例后端使用的端口                         | `number`      | -            | 是   | 有效范围：[1-65535]；ForceNew                        |
| `protocol`                  | 监听协议                                       | `string`      | `"http"`     | 否   | 有效值：`"http"`、`"https"`、`"tcp"`、`"udp"`      |
| `bandwidth`                 | 监听带宽峰值（Mbps）                           | `number`      | `-1`         | 否   | `-1` 表示无限；有效范围：[-1, 1-5000]                |
| `scheduler`                 | 调度算法                                       | `string`      | `"wrr"`      | 否   | 有效值：`"wrr"`、`"rr"`、`"wlc"`                   |
| `server_group_id`           | 绑定的服务器组 ID                              | `string`      | `""`         | 否   | 虚拟服务器组 ID                                      |
| `master_slave_server_group_id` | 主备服务器组 ID                               | `string`      | `""`         | 否   | 不能同时设置 `server_group_id` 和此字段             |
| `sticky_session`            | 是否开启会话持久性                             | `string`      | `"off"`      | 否   | 有效值：`"on"`、`"off"`                            |
| `sticky_session_type`       | 处理 Cookie 的模式                             | `string`      | `""`         | 否   | 如 `sticky_session` 为 `"on"` 则必填；值：`"insert"`、`"server"` |
| `cookie_timeout`            | Cookie 超时时间（秒）                          | `number`      | `0`          | 否   | 有效范围：[1-86400]；insert 模式必填               |
| `cookie`                    | 服务器上配置的 Cookie                          | `string`      | `""`         | 否   | server 模式必填                                    |
| `persistence_timeout`       | 连接持久性超时时间（TCP/UDP）                  | `number`      | `0`          | 否   | 有效范围：[0-3600] 秒                                |
| `health_check`              | 是否开启健康检查                               | `string`      | `"off"`      | 否   | TCP/UDP 始终开启；有效值：`"on"`、`"off"`          |
| `health_check_type`         | 健康检查类型                                   | `string`      | `"tcp"`      | 否   | 有效值：`"tcp"`、`"http"`                          |
| `health_check_domain`       | 健康检查使用的域名                             | `string`      | `""`         | 否   | TCP 监听的 HTTP 健康检查必填                        |
| `health_check_uri`          | 健康检查使用的 URI                             | `string`      | `""`         | 否   | 必须以 `/` 开头；长度 1-80                          |
| `health_check_connect_port` | 健康检查使用的端口                             | `number`      | `0`          | 否   | 默认使用后端端口；范围：[1-65535]                   |
| `healthy_threshold`         | 健康检查成功的阈值                             | `number`      | `3`          | 否   | 有效范围：[1-10]                                    |
| `unhealthy_threshold`       | 健康检查失败的阈值                             | `number`      | `3`          | 否   | 有效范围：[1-10]                                    |
| `health_check_timeout`      | 每次健康检查响应的最大超时时间                 | `number`      | `5`          | 否   | 有效范围：[1-300] 秒                                 |
| `health_check_interval`     | 健康检查的时间间隔                             | `number`      | `2`          | 否   | 有效范围：[1-50] 秒                                  |
| `health_check_http_code`    | 健康检查 HTTP 状态码                           | `string`      | `"http_2xx"` | 否   | 值：`http_2xx`、`http_3xx`、`http_4xx`、`http_5xx` |
| `server_certificate_id`     | SLB 服务器证书 ID                              | `string`      | `""`         | 否   | HTTPS 协议必填                                     |
| `ca_certificate_id`         | CA 证书 ID                                     | `string`      | `""`         | 否   | 用于 HTTPS 双向认证                                |
| `acl_status`                | 是否开启访问控制                               | `string`      | `"off"`      | 否   | 有效值：`"on"`、`"off"`                            |
| `acl_type`                  | 网络 ACL 类型                                  | `string`      | `""`         | 否   | 如 `acl_status` 为 `"on"` 则必填；值：`"black"`、`"white"` |
| `acl_id`                    | 网络 ACL ID                                    | `string`      | `""`         | 否   | 如 `acl_status` 为 `"on"` 则必填                   |
| `gzip`                      | 是否开启 Gzip 压缩                             | `bool`        | `true`       | 否   | 仅 HTTP/HTTPS                                      |
| `enable_http2`              | 是否开启 HTTP/2                                | `string`      | `"on"`       | 否   | 仅 HTTPS；值：`"on"`、`"off"`                     |
| `tls_cipher_policy`         | TLS 安全策略                                   | `string`      | `"tls_cipher_policy_1_0"` | 否 | 详见阿里云文档 |
| `established_timeout`       | TCP 已建立连接的空闲超时时间                   | `number`      | `900`        | 否   | 仅 TCP；有效范围：[10-900] 秒                       |

### 输出变量

| 名称              | 描述                                           |
|-------------------|------------------------------------------------|
| `id`              | 负载均衡监听 ID（格式：`<load_balancer_id>:<protocol>:<frontend_port>`） |
| `description`     | 监听描述                                       |

## 示例

更多典型使用模式，请参阅父模块的 `examples/` 目录：
- `create-slb-listener`：演示创建各种类型的监听

## 重要说明

- 🔗 **SLB 依赖**：此模块需要现有的 SLB 实例。确保在应用此模块之前已创建 SLB。
- 🔄 **ForceNew 字段**：`frontend_port`、`backend_port` 和 `protocol` 创建后无法更改。要修改，必须销毁并重新创建监听。
- 🏥 **TCP/UDP 健康检查**：TCP 和 UDP 监听始终启用健康检查，无法禁用。
- 🔒 **HTTPS 要求**：HTTPS 监听需要有效的 `server_certificate_id`。请使用 `slb_server_certificate` 资源创建证书。
- ⚖️ **互斥**：`server_group_id` 和 `master_slave_server_group_id` 不能同时设置。
- 📊 **带宽**：设置为 `-1` 表示无限带宽（推荐按流量计费的实例）。
- 🍪 **会话持久性**：启用时，选择 `insert`（SLB 管理 Cookie）或 `server`（后端管理 Cookie）模式。
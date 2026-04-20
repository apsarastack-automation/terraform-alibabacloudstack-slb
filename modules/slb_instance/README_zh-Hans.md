=====
# 阿里云 SLB 实例 Terraform 模块

此模块用于在阿里云专有云（Alibaba Cloud Stack）上创建和管理 **SLB（负载均衡）实例**，支持灵活的网络配置、规格选择和标签功能。

> ✅ **核心能力**：支持创建具有可自定义网络类型（公网/内网）、规格和 VSwitch 绑定的 SLB 实例。

## 功能特性

- ✅ **灵活的网络配置**  
  - 支持公网和内网 SLB 实例
  - 通过 VSwitch 绑定实现 VPC 集成
  - 支持经典网络（如适用）

- ✅ **规格管理**  
  - 多种性能层级：`slb.s1.small`、`slb.s2.small`、`slb.s2.medium` 等
  - 共享性能实例（默认，无规格）

- ✅ **资源标签**  
  - 支持阿里云资源标签
  - 环境和用途标记

- ✅ **全面的输出**  
  - 统一输出 SLB ID、名称、IP 地址、网络类型和关联的 VSwitch

> ⚠️ **注意**：此模块**不管理监听、后端服务器或服务器组**。请使用专用子模块（`slb_listener`、`slb_backend_server`、`slb_vserver_group`）实现这些功能。

## 使用方法

### 场景 1：在 VPC 中创建内网 SLB（推荐用于内部服务）

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

### 场景 2：创建公网 SLB（用于公共服务）

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

### 场景 3：创建共享性能 SLB（成本效益）

```hcl
module "slb_instance" {
  source = "./terraform-alibabacloudstack-slb-instance"

  name         = "dev-test-slb"
  address_type = "intranet"
  vswitch_id   = alibabacloudstack_vpc_vswitch.default.id
  # 不指定规格 = 共享性能实例

  tags = {
    Environment = "Development"
  }
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

| 名称              | 描述                                           | 类型          | 默认值         | 必填 | 说明                                                  |
|-------------------|------------------------------------------------|---------------|----------------|------|-------------------------------------------------------|
| `name`            | SLB 实例名称                                   | `string`      | `""`           | 是   | 在账户内必须唯一；最多 80 个字符；仅支持字母数字和连字符 |
| `address_type`    | SLB 实例的网络类型                             | `string`      | `"intranet"`   | 否   | 有效值：`"internet"`、`"intranet"`。VPC SLB 必须使用 `"intranet"` |
| `vswitch_id`      | 启动 SLB 的 VSwitch ID                         | `string`      | `""`           | 否*  | VPC SLB 必填；ForceNew；如 `address_type` 为 `"internet"` 则忽略 |
| `specification`   | SLB 实例的规格                                 | `string`      | `""`           | 否   | 有效值：`"slb.s1.small"`、`"slb.s2.small"`、`"slb.s2.medium"`、`"slb.s3.small"`、`"slb.s3.medium"`、`"slb.s3.large"`、`"slb.s4.large"`。空值 = 共享性能 |
| `network_type`    | SLB 实例的网络类型                             | `string`      | `"vpc"`        | 否   | 有效值：`"classic"`、`"vpc"`。默认值为 `vpc` |
| `tags`            | 分配给资源的标签映射                           | `map(string)` | `{}`           | 否   | -                                                     |

> 💡 **关键约束**：
> - `name` 必须在阿里云专有云账户内唯一
> - 创建 VPC SLB（`network_type = "vpc"`）时需要 `vswitch_id`
> - `address_type` 创建后无法更改（ForceNew）
> - 更改 `specification` 可能会导致短暂连接中断

### 输出变量

| 名称              | 描述                           |
|-------------------|--------------------------------|
| `id`              | 负载均衡器的 ID                |
| `name`            | 负载均衡器的名称               |
| `address`         | 负载均衡器的 IP 地址           |
| `address_type`    | 负载均衡器的地址类型           |
| `specification`   | 负载均衡器的规格               |
| `vswitch_id`      | 负载均衡器关联的 VSwitch ID    |
| `network_type`    | 负载均衡器的网络类型           |

## 示例

更多典型使用模式，请参阅父模块的 `examples/` 目录：
- `create-slb-instance`：演示使用不同配置创建 SLB 实例

## 重要说明

- 🚫 **不管理监听**：此模块仅创建 SLB 实例。请使用 `slb_listener` 子模块配置监听。
- 🚫 **不挂载后端**：后端服务器必须使用 `slb_backend_server` 或 `slb_vserver_group` 子模块单独挂载。
- 🌐 **地址分配**：公网 SLB 自动分配公网 IP。内网 SLB 使用 VSwitch CIDR 中的私有 IP。
- ⚠️ **规格限制**：每个规格具有不同的性能特性。详情请参阅阿里云文档。
- 🔒 **安全组**：SLB 实例不直接使用安全组。访问控制通过监听（ACL）或后端服务器安全组管理。
- 📍 **区域亲和性**：SLB 实例是区域特定的，无法跨区域。
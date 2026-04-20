=====
# 阿里云 SLB 虚拟服务器组 Terraform 模块

此模块用于在阿里云专有云（Alibaba Cloud Stack）上创建和管理 **SLB（负载均衡）虚拟服务器组**，允许将后端服务器灵活地组织成逻辑组以进行流量分发。

> ✅ **核心能力**：支持创建包含多个后端服务器（ECS 实例或 ENI）的虚拟服务器组，并将其与 SLB 监听关联。

## 功能特性

- ✅ **灵活的服务器组织**  
  - 将多个后端服务器逻辑分组
  - 支持 ECS 实例和 ENI
  - 为每个服务器配置端口和权重

- ✅ **多服务器支持**  
  - 将多个服务器添加到单个组
  - 每个服务器条目可配置不同端口和权重
  - 批量服务器管理

- ✅ **监听集成**  
  - 将虚拟服务器组绑定到监听
  - 基于 URL/域名的灵活流量路由（配合规则）

- ✅ **全面的输出**  
  - 输出组 ID、名称、关联的 SLB 和服务器列表

> ⚠️ **注意**：此模块**需要现有的 SLB 实例**。使用此模块之前必须先创建 SLB 实例。

## 使用方法

### 场景 1：创建包含 ECS 实例的虚拟服务器组

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

### 场景 2：创建包含多端口的虚拟服务器组

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

### 场景 3：创建包含 ENI 的虚拟服务器组

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

### 场景 4：与监听一起使用

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

| 名称                       | 描述                                           | 类型           | 默认值  | 必填 | 说明                                                  |
|----------------------------|------------------------------------------------|----------------|---------|------|-------------------------------------------------------|
| `load_balancer_id`         | SLB 实例 ID                                    | `string`       | -       | 是   | 必须是现有的 SLB 实例 ID；ForceNew                   |
| `name`                     | 虚拟服务器组名称                               | `string`       | `""`    | 否   | 人类可读的标识符                                      |
| `vserver_group_name`       | 虚拟服务器组的替代名称字段                     | `string`       | `""`    | 否   | 使用 `name` 或 `vserver_group_name` 之一             |
| `servers`                  | 要添加的后端服务器列表                         | `list(object)` | `[]`    | 否   | 每个资源最多 20 个服务器；详见服务器对象              |
| `delete_protection_validation` | 删除前检查 SLB 实例的删除保护                | `bool`         | `false` | 否   | 如为 true，当启用删除保护时阻止删除                   |

#### 服务器对象

| 名称         | 描述                           | 类型           | 默认值    | 必填 |
|--------------|--------------------------------|----------------|-----------|------|
| `server_ids` | 后端服务器 ID 列表             | `list(string)` | -         | 是   |
| `port`       | 后端服务器使用的端口           | `number`       | -         | 是   |
| `weight`     | 后端服务器的权重               | `number`       | `100`     | 否   |
| `type`       | 后端服务器类型                 | `string`       | `"ecs"`   | 否   |

> 💡 **关键约束**：
> - 一个资源中最多可添加 20 个服务器
> - `server_ids` 可包含多个 ID 以进行批量操作
> - `type` 有效值：`"ecs"`（ECS 实例）、`"eni"`（弹性网卡）
> - `weight` 有效范围：[0-100]
> - `port` 有效范围：[1-65535]

### 输出变量

| 名称                 | 描述                           |
|----------------------|--------------------------------|
| `id`                 | 虚拟服务器组 ID                |
| `load_balancer_id`   | 与组关联的负载均衡器 ID        |
| `name`               | 虚拟服务器组名称               |
| `vserver_group_name` | 虚拟服务器组名称（别名）       |
| `servers`            | 组中的服务器列表               |

## 示例

更多典型使用模式，请参阅父模块的 `examples/` 目录：
- `create-slb-with-vserver-group`：演示创建带虚拟服务器组的 SLB

## 重要说明

- 🔗 **SLB 依赖**：此模块需要现有的 SLB 实例。确保在应用此模块之前已创建 SLB。
- 📝 **命名**：使用 `name` 或 `vserver_group_name` 指定组名称。两者指向同一属性。
- ⚖️ **权重分配**：服务器权重决定流量分配。权重越高 = 流量越多。
- 🔄 **服务器更新**：修改 `servers` 列表将就地更新组。支持添加/删除服务器。
- 🛡️ **删除保护**：启用 `delete_protection_validation` 以防止意外删除受保护的 SLB。
- 🖥️ **服务器类型**：选择 `"ecs"` 表示 ECS 实例，或 `"eni"` 表示弹性网卡。
- 📊 **多端口支持**：创建具有不同端口的多个服务器条目以支持多端口应用。
- 🔒 **安全**：后端服务器必须具有适当的安全组规则以允许来自 SLB 的流量。
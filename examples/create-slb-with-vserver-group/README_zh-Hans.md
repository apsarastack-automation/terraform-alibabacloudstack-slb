# 创建带虚拟服务器组的 SLB 示例

此示例演示如何在阿里云专有云（Alibaba Cloud Stack）上创建带虚拟服务器组的 SLB（负载均衡）。

## 概述

此示例创建：
- SLB 实例
- 包含多个后端服务器的虚拟服务器组
- 绑定到虚拟服务器组的 HTTP 监听
- 作为后端服务器的 ECS 实例（可选）

## 使用方法

### 使用现有 ECS 实例的基础用法

```hcl
module "slb_instance" {
  source = "../../modules/slb_instance"

  name          = "web-tier-slb"
  address_type  = "intranet"
  vswitch_id    = "vsw-xxxxxxxx"
  specification = "slb.s2.small"
}

module "slb_vserver_group" {
  source = "../../modules/slb_vserver_group"

  load_balancer_id = module.slb_instance.id
  name             = "web-servers"

  servers = [
    {
      server_ids = ["i-xxxxxxxx", "i-yyyyyyyy"]
      port       = 80
      weight     = 100
      type       = "ecs"
    }
  ]
}

module "slb_listener" {
  source = "../../modules/slb_listener"

  load_balancer_id = module.slb_instance.id
  frontend_port    = 80
  backend_port     = 80
  protocol         = "http"
  server_group_id  = module.slb_vserver_group.id
}
```

### 使用新建 ECS 实例的完整设置

```hcl
# 创建 VPC 基础设施
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

# 创建 ECS 实例
resource "alibabacloudstack_ecs_instance" "web" {
  count             = 2
  image_id          = "ubuntu_18_04_x64_20G_alibase_20200618.vhd"
  instance_type     = "ecs.n4.small"
  vswitch_id        = alibabacloudstack_vpc_vswitch.default.id
  security_groups   = [alibabacloudstack_ecs_securitygroup.default.id]
  instance_name     = "web-server-${count.index + 1}"
}

# 创建 SLB
module "slb_instance" {
  source = "../../modules/slb_instance"

  name          = "web-tier-slb"
  address_type  = "intranet"
  vswitch_id    = alibabacloudstack_vpc_vswitch.default.id
  specification = "slb.s2.small"
}

# 创建虚拟服务器组
module "slb_vserver_group" {
  source = "../../modules/slb_vserver_group"

  load_balancer_id = module.slb_instance.id
  name             = "web-servers"

  servers = [
    {
      server_ids = alibabacloudstack_ecs_instance.web[*].id
      port       = 80
      weight     = 100
      type       = "ecs"
    }
  ]
}

# 创建监听
module "slb_listener" {
  source = "../../modules/slb_listener"

  load_balancer_id = module.slb_instance.id
  frontend_port    = 80
  backend_port     = 80
  protocol         = "http"
  server_group_id  = module.slb_vserver_group.id
  
  health_check = "on"
  health_check_type = "http"
  health_check_uri = "/health"
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

## 变量

| 名称            | 描述                           | 类型   | 默认值         | 必填 |
|-----------------|--------------------------------|--------|----------------|------|
| `vswitch_id`    | VSwitch ID                     | string | -              | 是   |
| `server_ids`    | ECS 实例 ID 列表               | list   | -              | 是   |
| `specification` | SLB 实例的规格                 | string | slb.s2.small   | 否   |

## 输出

| 名称               | 描述                           |
|--------------------|--------------------------------|
| `slb_id`           | 创建的 SLB ID                  |
| `slb_address`      | SLB 的地址                     |
| `vserver_group_id` | 虚拟服务器组 ID                |

## 运行示例

1. 初始化 Terraform：
   ```bash
   terraform init
   ```

2. 规划部署：
   ```bash
   terraform plan
   ```

3. 应用配置：
   ```bash
   terraform apply
   ```

4. 销毁资源（完成后）：
   ```bash
   terraform destroy
   ```

## 说明

- 后端服务器（ECS 实例）必须与 SLB 在同一 VPC 中。
- 虚拟服务器组必须在引用它的监听之前创建。
- 服务器权重决定后端服务器之间的流量分配。
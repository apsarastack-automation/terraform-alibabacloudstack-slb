# 创建 SLB 实例示例

此示例演示如何使用 `slb_instance` 子模块在阿里云专有云（Alibaba Cloud Stack）上创建基础 SLB（负载均衡）实例。

## 概述

此示例创建：
- VPC 和 VSwitch（如不存在）
- 具有指定规格的内网 SLB 实例
- 用于资源组织的标签

## 使用方法

### 基础用法

```hcl
module "slb_instance" {
  source = "../../modules/slb_instance"

  name          = "my-slb-instance"
  address_type  = "intranet"
  vswitch_id    = "vsw-xxxxxxxx"
  specification = "slb.s1.small"

  tags = {
    Environment = "Test"
    CreatedBy   = "Terraform"
  }
}
```

### 使用新建 VPC

```hcl
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

module "slb_instance" {
  source = "../../modules/slb_instance"

  name          = "my-slb-instance"
  address_type  = "intranet"
  vswitch_id    = alibabacloudstack_vpc_vswitch.default.id
  specification = "slb.s2.small"

  tags = {
    Environment = "Production"
    Project     = "Demo"
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

## 变量

| 名称            | 描述                           | 类型   | 默认值         | 必填 |
|-----------------|--------------------------------|--------|----------------|------|
| `name`          | SLB 实例名称                   | string | -              | 是   |
| `vswitch_id`    | VSwitch ID（用于内网 SLB）     | string | -              | 是   |
| `specification` | SLB 实例的规格                 | string | `slb.s1.small` | 否   |

## 输出

| 名称       | 描述                    |
|------------|-------------------------|
| `slb_id`   | 创建的 SLB ID           |
| `address`  | SLB 的 IP 地址          |

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

- 此示例仅创建 SLB 实例，不包含任何监听或后端服务器。
- 如需包含监听和后端服务器的完整设置，请参阅父目录中的其他示例。
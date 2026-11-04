ecs_cluster
===========

An ECS cluster on EC2 hosts in an Auto Scaling group, with a capacity
provider, the hosts' security group and IAM role, and a CloudWatch log group
(`/ecs/cluster/<name>`) for the hosts' logs.

Each host runs the CloudWatch agent, which ships the ECS agent's logs
(`ecs-init.log`, `ecs-agent.log`, `audit.log`) and the system journal to the
cluster's log group, one stream per instance and file
(`<instance id>/journal`, `<instance id>/ecs-agent.log`, ...). Hosts are
reachable with SSM Session Manager (`AmazonSSMManagedInstanceCore`), and their
root volumes are encrypted.

Variables
---------

### General

| Variable             | Type          | Default    | Description                                                        |
|----------------------|---------------|------------|--------------------------------------------------------------------|
| `name`               | `string`      | -          | Cluster name                                                       |
| `vpc`                | `object`      | -          | `id`, `cidr_block`, `public_subnet_ids`, `private_subnet_ids`      |
| `tagging`            | `object`      | -          | `managed_by`, `production`                                         |
| `type`               | `string`      | `"public"` | `public` or `private`: which of the VPC's subnets the hosts go in  |
| `container_insights` | `bool`        | `false`    | Enable Container Insights on the cluster                           |
| `log_retention_days` | `number`      | `7`        | Retention of the cluster's log group, in days                      |
| `instance_tags`      | `map(string)` | `{}`       | Tags added to the hosts and their volumes (the provider's default tags don't reach instances an Auto Scaling group launches) |

### Hosts

| Variable            | Type     | Default                                                                  | Description                                                   |
|---------------------|----------|--------------------------------------------------------------------------|---------------------------------------------------------------|
| `instance_type`     | `string` | `"t3.small"`                                                             | Host instance type                                            |
| `image_parameter`   | `string` | `"/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"` | SSM parameter holding the hosts' image ID                     |
| `image_id`          | `string` | `null`                                                                   | Hosts' image ID. Overrides `image_parameter`                  |
| `initial_hosts`     | `number` | `1`                                                                      | Initial size of the Auto Scaling group                        |
| `min_hosts`         | `number` | `1`                                                                      | Minimum number of hosts                                       |
| `max_hosts`         | `number` | `2`                                                                      | Maximum number of hosts                                       |
| `assign_public_ips` | `bool`   | `null`                                                                   | Give the hosts public IP addresses                            |
| `key_pair`          | `string` | `null`                                                                   | Unused                                                        |
| `users`             | `list(object({ name = string, ssh = string }))` | `[]`              | Users added to the hosts, with sudo and the given SSH key     |

The host start-up config assumes an ECS-optimized Amazon Linux image (root
device `/dev/xvda`, `dnf`/`yum` packages `amazon-cloudwatch-agent` and
`logrotate`). An `image_id` override should be one too.

### Access

| Variable         | Type   | Default | Description                                                                                    |
|------------------|--------|---------|------------------------------------------------------------------------------------------------|
| `ssh_access`     | `bool` | `true`  | Open port 22 on the hosts to `0.0.0.0/0`. `false` removes the rule                             |
| `require_imdsv2` | `bool` | `false` | Require IMDSv2 with a hop limit of 1, so containers can't reach the host's credentials. Tasks use their task roles |

The hosts' security group always accepts all traffic from inside the VPC.

### Scaling

| Variable           | Type     | Default | Description                                                                 |
|--------------------|----------|---------|-----------------------------------------------------------------------------|
| `auto_scale`       | `bool`   | `true`  | Scale the hosts with a capacity provider                                    |
| `min_scaling_step` | `number` | `1`     | Capacity provider's minimum scaling step (1-10000)                          |
| `max_scaling_step` | `number` | `3`     | Capacity provider's maximum scaling step (1-10000)                          |
| `target_capacity`  | `number` | `null`  | Capacity provider's target utilization, in percent (99 in production, else 100) |

### Unused

`shared_data` and `logging` are accepted but currently have no effect.

```
module "cluster" {
  source = "github.com/tfext/terraform-aws-ecs-cluster?ref=<tag>"

  name               = "my-cluster"
  vpc                = module.vpc_data
  tagging            = module.tagging
  ssh_access         = false
  require_imdsv2     = true
  container_insights = true
  instance_tags      = { env = "production" }
  log_retention_days = 90
}
```

Outputs
-------

| Output                   | Description                                               |
|--------------------------|-----------------------------------------------------------|
| `id`                     | Cluster ID                                                |
| `arn`                    | Cluster ARN                                               |
| `name`                   | Cluster name                                              |
| `capacity_provider_name` | Capacity provider name (`<name>-capacity-provider`), or `null` when `auto_scale` is false |
| `security_group_id`      | Hosts' security group                                     |
| `host_role_name`         | Hosts' IAM role name                                      |
| `autoscaling_group_name` | Hosts' Auto Scaling group name                            |
| `log_group_name`         | Cluster's log group name                                  |
| `autoscale_role_arn`     | Role for application auto scaling of the cluster's services |

Upgrading
---------

The default `image_parameter` moved from Amazon Linux 2 to Amazon Linux 2023,
and the launch template's root volume is now encrypted. Both change the launch
template, so hosts launched after the next apply use the new image; existing
hosts keep running until they're replaced. Set `image_parameter` to
`/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id` to stay on
Amazon Linux 2.

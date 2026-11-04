variable "name" {
  type = string
}

variable "vpc" {
  type = object({
    id = string
    cidr_block = string
    public_subnet_ids = list(string)
    private_subnet_ids = list(string)
  })
}

variable "tagging" {
  type = object({
    managed_by = string
    production = bool
  })
}

variable "type" {
  type = string
  default = "public"
  validation {
    condition = var.type == "public" || var.type == "private"
    error_message = "Cluster type must be public or private"
  }
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "initial_hosts" {
  type    = number
  default = 1
}

variable "max_hosts" {
  type    = number
  default = 2
}

variable "min_hosts" {
  type    = number
  default = 1
}

variable "min_scaling_step" {
  default = 1
  validation {
    condition     = var.min_scaling_step >= 1 && var.min_scaling_step <= 10000
    error_message = "Must be between 1 and 10000."
  }
}

variable "max_scaling_step" {
  default = 3
  validation {
    condition     = var.max_scaling_step >= 1 && var.max_scaling_step <= 10000
    error_message = "Must be between 1 and 10000."
  }
}

variable "target_capacity" {
  type        = number
  default     = null
  description = "Percentage of target tracking cloudwatch metric utilization"
}

# variable "load_balancers" {
#   type = list(string)
#   default = []
#   description = "List of load balancer ARNs that will be used to access cluster services"
# }

variable "shared_data" {
  type        = bool
  default     = false
  description = "Create a shared EFS that can be mounted to containers for persisting shared data"
}

variable "key_pair" {
  type    = string
  default = null
}

# variable "backup_vault" {
#   type    = string
#   default = null
# }

variable "logging" {
  type    = string
  default = null

  validation {
    condition     = var.logging == null || can(regex("^(aws|fluent)$", var.logging))
    error_message = "Logging must be aws or fluent (default)"
  }
}

# variable "ami_name" {
#   type    = string
#   default = "amzn2-ami-ecs-hvm-*-x86_64-ebs"
# }

# variable "ami_owner" {
#   type    = string
#   default = "amazon"
# }

variable "auto_scale" {
  default     = true
  description = "Auto-scale hosts using a capacity provider"
}

variable "assign_public_ips" {
  type    = bool
  default = null
}

variable "users" {
  type = list(object({
    name = string
    ssh = string
  }))
  default = []
  description = "Add users with SSH access to container host instances"
}

variable "image_parameter" {
  type        = string
  default     = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended/image_id"
  description = "SSM parameter holding the hosts' image ID. Ignored when image_id is set"
}

variable "image_id" {
  type        = string
  default     = null
  description = "Hosts' image ID. Overrides image_parameter"
}

variable "ssh_access" {
  type        = bool
  default     = true
  description = "Open port 22 on the hosts to 0.0.0.0/0"
}

variable "require_imdsv2" {
  type        = bool
  default     = false
  description = "Require IMDSv2 on the hosts, with a hop limit of 1 so containers can't reach the host's credentials"
}

variable "container_insights" {
  type        = bool
  default     = false
  description = "Enable Container Insights on the cluster"
}

variable "log_retention_days" {
  type        = number
  default     = 7
  description = "Retention of the cluster's log group, in days"
}

variable "instance_tags" {
  type        = map(string)
  default     = {}
  description = "Tags added to the hosts and their volumes"
}

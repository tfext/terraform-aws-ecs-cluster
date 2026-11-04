output "id" {
  value = aws_ecs_cluster.main.id
}

output "arn" {
  value = aws_ecs_cluster.main.arn
}

output "security_group_id" {
  value = aws_security_group.ecs_hosts.id
}

output "autoscale_role_arn" {
  value = aws_iam_role.ecs_autoscale.arn
}

output "name" {
  value = aws_ecs_cluster.main.name
}

output "capacity_provider_name" {
  value       = try(aws_ecs_capacity_provider.capacity_provider[0].name, null)
  description = "Null when auto_scale is false"
}

output "host_role_name" {
  value = aws_iam_role.ecs_host.name
}

output "autoscaling_group_name" {
  value = aws_autoscaling_group.ecs_hosts.name
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.cluster.name
}

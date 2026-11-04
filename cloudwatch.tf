resource "aws_cloudwatch_log_group" "cluster" {
  name = "/ecs/cluster/${var.name}"
  retention_in_days = var.log_retention_days
}

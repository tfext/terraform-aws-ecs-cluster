resource "aws_security_group" "ecs_hosts" {
  name   = "${var.name}_ecs_hosts"
  vpc_id = var.vpc.id
  tags   = { Name = "${var.name}_ecs_hosts" }
}

resource "aws_security_group_rule" "ecs_hosts_ssh" {
  count             = var.ssh_access ? 1 : 0
  security_group_id = aws_security_group.ecs_hosts.id
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Global access for testing (${var.tagging.managed_by})"
}

moved {
  from = aws_security_group_rule.ecs_hosts_ssh
  to   = aws_security_group_rule.ecs_hosts_ssh[0]
}

resource "aws_security_group_rule" "ecs_hosts_internal" {
  security_group_id = aws_security_group.ecs_hosts.id
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  type              = "ingress"
  cidr_blocks       = [var.vpc.cidr_block]
  description       = "Internal access for health checks etc (${var.tagging.managed_by})"
}

resource "aws_security_group_rule" "ecs_hosts_outbound" {
  security_group_id = aws_security_group.ecs_hosts.id
  type              = "egress"
  protocol          = "-1"
  from_port         = "0"
  to_port           = "0"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "All access from hosts to the internet (${var.tagging.managed_by})"
}


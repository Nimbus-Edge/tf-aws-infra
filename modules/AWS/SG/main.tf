resource "aws_security_group" "security_group" {
  vpc_id = var.vpc_id

  # Ingress rules
  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = var.protocol
      cidr_blocks     = var.source_security_group_ids != [] ? [] : [var.ingress_cidr]
      security_groups = var.source_security_group_ids != [] ? var.source_security_group_ids : []
    }
  }

  # Egress rules
  dynamic "egress" {
    for_each = var.egress_ports
    content {
      from_port   = egress.value == -1 ? 0 : egress.value
      to_port     = egress.value == -1 ? 65535 : egress.value
      protocol    = var.egress_protocol
      cidr_blocks = [var.egress_cidr]
    }
  }

  tags = {
    Name = "${var.source_security_group_ids != [] ? "DBSecurityGroup" : "AppSecurityGroup"}-${var.unique_suffix}"
  }
}

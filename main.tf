

resource "aws_lb" "balanceador" {
  name               = lookup(var.lb_config, "name")
  load_balancer_type = var.lb_type

  subnets = [for st in var.lb_subnets : "${st}"]

  security_groups = length(aws_security_group.sg_lb) > 0 ? ["${aws_security_group.sg_lb[0].id}"] : null

  enable_deletion_protection = false

  enable_cross_zone_load_balancing = true

  tags = {
    Environment = lookup(var.lb_config, "environment")
  }
}


resource "aws_security_group" "sg_lb" {

  # Solo si el balanceador es de tipo "application" creará este recurso
  count = format("%.1s", var.lb_type) == "a" ? 1 : 0

  name        = "sg_${lookup(var.lb_config, "name")}"
  description = "SG para el ALB"
  vpc_id      = var.lb_vpc

  # HTTP

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.key
      to_port     = ingress.key
      protocol    = ingress.value
      cidr_blocks = ["${var.ingress_cidr}"]
    }
  }

  # Trafico de Salida
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_lb_target_group" "tg_lb" {
  for_each = var.lsn_ports
  name     = "tg-port${each.key}-${each.value}"
  port     = each.key
  protocol = each.value

  vpc_id = var.lb_vpc

  target_type = "%{if var.lb_type == "network"}ip%{else}instance%{endif}"

  deregistration_delay = lookup(var.tg_config, "dereg_delay")

  health_check {
    port                = lookup(var.tg_healthchk, "port")
    protocol            = lookup(var.tg_healthchk, "protocol")
    healthy_threshold   = lookup(var.tg_healthchk, "healthy_threshold")
    unhealthy_threshold = lookup(var.tg_healthchk, "unhealthy_threshold")
    timeout             = var.lb_type == "application" ? lookup(var.tg_healthchk, "timeout") : null
    interval            = lookup(var.tg_healthchk, "interval")
  }

  tags = {
    Environment = lookup(var.lb_config, "environment")
  }
}


resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.balanceador.arn


  for_each = var.lsn_ports
  port     = each.key
  protocol = each.value

  default_action {
    target_group_arn = aws_lb_target_group.tg_lb[each.key].arn 
    type             = "forward"
  }
}



# Esto cuando vayamos a attacharlo 
#resource "aws_lb_target_group_attachment" "tg_attach" {
#  for_each = var.lsn_ports
#    target_group_arn  	= aws_lb_target_group.tg_lb[each.key].arn
#    port 		= each.key
#
#  target_id		= var.tgatt_targetid
#}

# ARN de los Target Groups Creados
output "targetgroup_arn" {
  description = "ARN de los Target Group Creados"
  value       = values(aws_lb_target_group.tg_lb)[*].arn
}

# Nombre DNS balanceador
output "lb_dns" {
  description = "DNS Load Balancer"
  value = aws_lb.balanceador.dns_name
}

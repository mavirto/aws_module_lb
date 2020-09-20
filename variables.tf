variable "lb_vpc" {}

variable "lb_type" {}

variable "lb_subnets" {
  type = list(string)
}

variable "lb_config" {
  type = map(string)
}

variable "tg_config" {
  type = map(string)
}

variable "tg_healthchk" {
  type = map(string)
}

variable "lsn_ports" {
  type = map(string)
}

variable "ingress_ports" {
  type = map(string)
}

variable "ingress_cidr" {
}

variable "project" {
  default = "roboshop"
}

variable "environment" {
  default = "dev"
}

variable "frontend_sg_name" {
  default = "frontend"
}

variable "sg_description" {
  default = "frontend ports"
}

variable "bastion_sg_name" {
  default = "bastion"
}

variable "bastion_sg_description" {
  default = "created for bastion instance"
}

variable "mongodb_ports_vpn" {
  default = [22, 27017]
}

variable "reddis_port_vpn" {
  default = [22, 6379]
}

variable "mysql_port_vpn" {
  default = [22, 3306]
}

variable "rabbitmq_port_vpn" {
  default = [22, 5672]
}
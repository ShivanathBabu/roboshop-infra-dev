module "frontend" {
  #source = "../terraform-aws-securitygroup"
  source = "git::https://github.com/ShivanathBabu/terraform-aws-securitygroup.git?ref=main"
  project = var.project
  environment = var.environment
  sg_name = var.frontend_sg_name
  sg_description = var.sg_description
  vpc_id = local.vpc_id
}

# security group for bastion host

module "bastion" {
  source = "git::https://github.com/ShivanathBabu/terraform-aws-securitygroup.git?ref=main"
  project = var.project
  environment = var.environment
  sg_name = var.bastion_sg_name
  sg_description = var.bastion_sg_description
  vpc_id = local.vpc_id
}

#security group for backen alb

module "backend_ALB" {
  source = "git::https://github.com/ShivanathBabu/terraform-aws-securitygroup.git?ref=main"
  project = var.project
  environment = var.environment
  sg_name = "backend-alb"
  sg_description = "for backend alb"
  vpc_id = local.vpc_id

}

# vpn security group

module "vpn" {
  source = "git::https://github.com/ShivanathBabu/terraform-aws-securitygroup.git?ref=main"
  project = var.project
  environment = var.environment
  sg_name = "vpn"
  sg_description = "for vpn"
  vpc_id = local.vpc_id

}

# mongodb security group

module "mongodb" {
  source = "git::https://github.com/ShivanathBabu/terraform-aws-securitygroup.git?ref=main"
  project = var.project
  environment = var.environment
  sg_name = "mongoDB"
  sg_description = "for mongoDB"
  vpc_id = local.vpc_id
}

module "rabbitmq" {
  source = "git::https://github.com/ShivanathBabu/terraform-aws-securitygroup.git?ref=main"
  project = var.project
  environment = var.environment
  sg_name = "rabbitmq"
  sg_description = "for rabbitmq"
  vpc_id = local.vpc_id
}

module "reddis" {
  source = "git::https://github.com/ShivanathBabu/terraform-aws-securitygroup.git?ref=main"
  project = var.project
  environment = var.environment
  sg_name = "reddis"
  sg_description = "reddis"
  vpc_id = local.vpc_id
}

module "mysql" {
  source = "git::https://github.com/ShivanathBabu/terraform-aws-securitygroup.git?ref=main"
  project = var.project
  environment = var.environment
  sg_name = "mysql"
  sg_description = "for mysql"
  vpc_id = local.vpc_id
}

module "catalogue" {
  source = "git::https://github.com/ShivanathBabu/terraform-aws-securitygroup.git?ref=main"
  project = var.project
  environment = var.environment
  sg_name = "catalogue"
  sg_description = "for catalogue"
  vpc_id = local.vpc_id
}

module "user" {
  source = "git::https://github.com/ShivanathBabu/terraform-aws-securitygroup.git?ref=main"
  project = var.project
  environment = var.environment
  sg_name = "user"
  sg_description = "for user"
  vpc_id = local.vpc_id
}

module "cart" {
  source = "git::https://github.com/ShivanathBabu/terraform-aws-securitygroup.git?ref=main"
  project = var.project
  environment = var.environment
  sg_name = "cart"
  sg_description = "for cart"
  vpc_id = local.vpc_id
}

module "shipping" {
  source = "git::https://github.com/ShivanathBabu/terraform-aws-securitygroup.git?ref=main"
  project = var.project
  environment = var.environment
  sg_name = "shipping"
  sg_description = "for shipping"
  vpc_id = local.vpc_id
}

module "payment" {
  source = "git::https://github.com/ShivanathBabu/terraform-aws-securitygroup.git?ref=main"
  project = var.project
  environment = var.environment
  sg_name = "payment"
  sg_description = "for payment"
  vpc_id = local.vpc_id
}

module "frontend_alb" {
  source = "git::https://github.com/ShivanathBabu/terraform-aws-securitygroup.git?ref=main"
  project = var.project
  environment = var.environment
  sg_name = "frontend_alb"
  sg_description = "for frontend_alb"
  vpc_id = local.vpc_id
}

resource "aws_security_group_rule" "frontend_vpn" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.frontend.sg_id
}

resource "aws_security_group_rule" "frontend_bastion" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.frontend.sg_id
}

resource "aws_security_group_rule" "frontend_frontend_alb" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  source_security_group_id = module.frontend_alb.sg_id
  security_group_id = module.frontend.sg_id
}

resource "aws_security_group_rule" "frontend_alb_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.backend_ALB.sg_id
}

resource "aws_security_group_rule" "frontend_alb_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.frontend_alb.sg_id
}


#bastion accepting connection from my laptop
resource "aws_security_group_rule" "bastion_laptop" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  #if you are using office network provide office cidr block
  security_group_id =  module.bastion.sg_id  # security group output sg_id which is mentioned terraform-aws-security
}

# Backend ALB accpeting connections from my bastion host on port no 80
resource "aws_security_group_rule" "backend_alb_bastion" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.backend_ALB.sg_id

}

# allow port 80 from vpn to backend alb
resource "aws_security_group_rule" "backend_alb_vpn" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.backend_ALB.sg_id

}

resource "aws_security_group_rule" "backend_alb_frontend" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.frontend_alb.sg_id
  security_group_id = module.backend_ALB.sg_id
}

resource "aws_security_group_rule" "backend_alb_cart" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  source_security_group_id = module.cart.sg_id
  security_group_id = module.backend_ALB.sg_id
}

resource "aws_security_group_rule" "backend_alb_shipping" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  source_security_group_id = module.shipping.sg_id
  security_group_id = module.backend_ALB.sg_id
}

resource "aws_security_group_rule" "backend_alb_payment" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  source_security_group_id = module.payment.sg_id
  security_group_id = module.backend_ALB.sg_id
}




# vpn port no 22, 443, 1194 , 943

resource "aws_security_group_rule" "vpn_ssh" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

resource "aws_security_group_rule" "vpn_http" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

resource "aws_security_group_rule" "vpn_1194" {
  type = "ingress"
  from_port = 1194
  to_port = 1194
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

resource "aws_security_group_rule" "vpn_943" {
  type = "ingress"
  from_port = 943
  to_port = 943
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

# allow port 22 and 27017 from vpn to mongodb

resource "aws_security_group_rule" "mongodb_vpn" {
  count = length(var.mongodb_ports_vpn)
  type = "ingress"
  from_port = var.mongodb_ports_vpn[count.index]
  to_port = var.mongodb_ports_vpn[count.index]
  protocol = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.mongodb.sg_id
}



resource "aws_security_group_rule" "mongodb_bastion" {
  count = length(var.mongodb_ports_vpn)
  type = "ingress"
  from_port = var.mongodb_ports_vpn[count.index]
  to_port = var.mongodb_ports_vpn[count.index]
  protocol = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.mongodb.sg_id
}

# catalogue to backend_alb 8080
resource "aws_security_group_rule" "catalogue_backend_alb" {
  type = "ingress"
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  source_security_group_id = module.backend_ALB.sg_id
  security_group_id = module.catalogue.sg_id
}

# catalogue to vpn 22
resource "aws_security_group_rule" "catalogue_vpn_ssh" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.catalogue.sg_id
}

# catalogue to vpn 8080
resource "aws_security_group_rule" "catalogue_http" {
  type = "ingress"
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.catalogue.sg_id
}

resource "aws_security_group_rule" "catalogue_bastion_ssh" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.catalogue.sg_id
}

resource "aws_security_group_rule" "mongodb_catalogue" {
  type = "ingress"
  from_port = 27017
  to_port = 27017
  protocol = "tcp"
  source_security_group_id = module.catalogue.sg_id
  security_group_id = module.mongodb.sg_id
}

resource "aws_security_group_rule" "mongodb_user" {
  type = "ingress"
  from_port = 27017
  to_port = 27017
  protocol = "tcp"
  source_security_group_id = module.user.sg_id
  security_group_id = module.mongodb.sg_id
}

# reddis

resource "aws_security_group_rule" "reddis_vpn" {
  count = length(var.reddis_port_vpn)
  type = "ingress"
  from_port = var.reddis_port_vpn[count.index]
  to_port = var.reddis_port_vpn[count.index]
  protocol = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.reddis.sg_id
}

resource "aws_security_group_rule" "reddis_bastion" {
  count = length(var.reddis_port_vpn)
  type = "ingress"
  from_port = var.reddis_port_vpn[count.index]
  to_port = var.reddis_port_vpn[count.index]
  protocol = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.reddis.sg_id
}

resource "aws_security_group_rule" "reddis_user" {
  type = "ingress"
  from_port = 6379
  to_port = 6379
  protocol = "tcp"
  source_security_group_id = module.user.sg_id
  security_group_id = module.reddis.sg_id
}

resource "aws_security_group_rule" "reddis_cart" {
  type = "ingress"
  from_port = 6379
  to_port = 6379
  protocol = "tcp"
  source_security_group_id = module.cart.sg_id
  security_group_id = module.reddis.sg_id
}

#mysql


resource "aws_security_group_rule" "mysql_bastion" {
  count = length(var.mysql_port_vpn)
  type = "ingress"
  from_port = var.mysql_port_vpn[count.index]
  to_port = var.mysql_port_vpn[count.index]
  protocol = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.mysql.sg_id
}

resource "aws_security_group_rule" "mysql_vpn" {
  count = length(var.mysql_port_vpn)
  type = "ingress"
  from_port = var.mysql_port_vpn[count.index]
  to_port = var.mysql_port_vpn[count.index]
  protocol = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.mysql.sg_id
}

resource "aws_security_group_rule" "mysql_shipping" {
  type = "ingress"
  from_port = 3306
  to_port = 3306
  protocol = "tcp"
  source_security_group_id = module.shipping.sg_id
  security_group_id = module.mysql.sg_id
}

# rabbitmq
resource "aws_security_group_rule" "rabbitmq_vpn" {
  count = length(var.rabbitmq_port_vpn)
  type = "ingress"
  from_port = var.rabbitmq_port_vpn[count.index]
  to_port = var.rabbitmq_port_vpn[count.index]
  protocol = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.rabbitmq.sg_id
}

resource "aws_security_group_rule" "rabbitmq_bastion" {
  count = length(var.rabbitmq_port_vpn)
  type = "ingress"
  from_port = var.rabbitmq_port_vpn[count.index]
  to_port = var.rabbitmq_port_vpn[count.index]
  protocol = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.rabbitmq.sg_id
}

resource "aws_security_group_rule" "rabbitmq_payment" {
  type              = "ingress"
  from_port         = 5672
  to_port           = 5672
  protocol          = "tcp"
  source_security_group_id = module.payment.sg_id
  security_group_id = module.rabbitmq.sg_id
}

# user

resource "aws_security_group_rule" "user_vpn_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.user.sg_id
}

resource "aws_security_group_rule" "user_bastion_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.user.sg_id
}

resource "aws_security_group_rule" "user_vpn_http" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.user.sg_id
}

resource "aws_security_group_rule" "user_backend_alb" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.backend_ALB.sg_id
  security_group_id = module.user.sg_id
}

# cart

resource "aws_security_group_rule" "cart_vpn_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.cart.sg_id
}

resource "aws_security_group_rule" "cart_bastion_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.cart.sg_id
}

resource "aws_security_group_rule" "cart_vpn_http" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.cart.sg_id
}

resource "aws_security_group_rule" "cart_backend_alb" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.backend_ALB.sg_id
  security_group_id = module.cart.sg_id
}

#Shipping
resource "aws_security_group_rule" "shipping_vpn_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.shipping.sg_id
}

resource "aws_security_group_rule" "shipping_bastion_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.shipping.sg_id
}

resource "aws_security_group_rule" "shipping_vpn_http" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.shipping.sg_id
}

resource "aws_security_group_rule" "shipping_backend_alb" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.backend_ALB.sg_id
  security_group_id = module.shipping.sg_id
}

#Payment
resource "aws_security_group_rule" "payment_vpn_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.payment.sg_id
}

resource "aws_security_group_rule" "payment_bastion_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.payment.sg_id
}

resource "aws_security_group_rule" "payment_vpn_http" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.payment.sg_id
}

resource "aws_security_group_rule" "payment_backend_alb" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.backend_ALB.sg_id
  security_group_id = module.payment.sg_id
}



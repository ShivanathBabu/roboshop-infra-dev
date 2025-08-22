module "backend_alb" {
  source = "terraform-aws-modules/alb/aws"
  version = "9.16.0"
  internal = true #private load balancer set true
  name    = "${var.project}-${var.environment}-backen-alb"
  vpc_id  = local.vpc_id
  subnets = local.private_subnet_id

  # Security Group
  create_security_group = false
  security_groups = [local.backen_alb_sg_id]

  enable_deletion_protection = false

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-backend-alb"
    } 
  )
}

resource "aws_alb_listener" "backend_alb" {
  load_balancer_arn = module.backend_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1> Hello I am From Backend ALB </h1>"
      status_code  = "200"
    }
  }
}

resource "aws_route53_record" "backend_alb" {
  zone_id = var.zone_id
  name = "*.backend-dev.${var.zone_name}"
  type = "A"

  alias {
    name          = module.backend_alb.dns_name  # dns_name and zone_id is to verify from module alb, in there module they have mentioned as dns_name so we nnedd to verify and mention in our code
    zone_id       = module.backend_alb.zone_id
    evaluate_target_health = true
  }
}
module "frontend_alb" {
  source = "terraform-aws-modules/alb/aws"
  version = "9.16.0"
  internal = false #private load balancer set true
  name    = "${var.project}-${var.environment}-frontend-alb"
  vpc_id  = local.vpc_id
  subnets = local.public_subnet_id

  # Security Group
  create_security_group = false
  security_groups = [local.frontend_alb_sg_id]

  enable_deletion_protection = false

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-frontend-alb"
    } 
  )
}

resource "aws_alb_listener" "frontend_alb" {
  load_balancer_arn = module.frontend_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn = local.acm_certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1> Hello I am From frontned ALB </h1>"
      status_code  = "200"
    }
  }
}

resource "aws_route53_record" "frontend_alb" {
  zone_id = var.zone_id
  name = "*.${var.zone_name}"
  type = "A"

  alias {
    name          = module.frontend_alb.dns_name  # dns_name and zone_id is to verify from module alb, in there module they have mentioned as dns_name so we nnedd to verify and mention in our code
    zone_id       = module.frontend_alb.zone_id
    evaluate_target_health = true
  }
}
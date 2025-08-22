locals {
  ami_id = data.aws_ami.blackweb_agency.id
 
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  
  private_subnet_id = split (",", data.aws_ssm_parameter.private_subnet_ids.value)[0]
  private_subnet_ids = split (",", data.aws_ssm_parameter.private_subnet_ids.value)
  
  backend_alb_listner_arn = data.aws_ssm_parameter.backend_aws_listner_arn.value
  frontend_alb_listner_arn = data.aws_ssm_parameter.frontend_alb_listner_arn.value
  
  sg_id = data.aws_ssm_parameter.sg_id.value
  

  alb_listner_arn = "${var.component}" == "frontend" ? local.frontend_alb_listner_arn : local.backend_alb_listner_arn

  tg_port = "${var.component}" == "frontend" ? 80 : 8080
  health_check_path = "${var.component}" == "frontend" ? "/" : "/health"

  rulle_header_url = "${var.component}" == "frontend" ? "${var.environment}.${var.zone_name}" : "${var.component}.backend-${var.environment}.${var.zone_name}"
  common_tags = {
    project = var.project
    environment =  var.environment
    terraform = true
  }
} 
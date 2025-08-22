locals {
  ami_id = data.aws_ami.blackweb_agency.id
  vpc_id = data.aws_ssm_parameter.vpc_id.value
  private_subnet_id = split (",", data.aws_ssm_parameter.private_subnet_ids.value)[0]
  private_subnet_ids = split (",", data.aws_ssm_parameter.private_subnet_ids.value)
  catalogue_sg_id = data.aws_ssm_parameter.catalogue_sg_id.value
  backend_alb_listner_arn = data.aws_ssm_parameter.aws_listner.value
 
  common_tags = {
    project = var.project
    environment =  var.environment
    terraform = true
  }
} 
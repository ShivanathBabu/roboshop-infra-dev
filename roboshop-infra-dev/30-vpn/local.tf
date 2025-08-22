locals {
  ami_id = data.aws_ami.OpenVPN.id
  vpn_sg_id = data.aws_ssm_parameter.vpn_sg_id.value
  public_subnet_id = split (",", data.aws_ssm_parameter.public_subnet_ids.value)[0] # to get public subnet 0: means first subnet 

  common_tags = {
      project = var.project
      environment = var.environment
      terraform = "true"
  }
}
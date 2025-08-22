resource "aws_instance" "bastion" {
  ami = local.ami_id
  instance_type = "t3.micro"
  vpc_security_group_ids = [local.bastion_sg_id]
  # what if i doesn't mention subnet a) it will create in default vpc in default subnet
  subnet_id = local.public_subnet_id

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-bastion"
    }
  )
    
}

#request for security group to security team

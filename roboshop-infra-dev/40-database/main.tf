#mongodb
resource "aws_instance" "mongodb" {
  ami = local.ami_id
  instance_type = "t3.micro"
   # what if i doesn't mention subnet a) it will create in default vpc in default subnet
  subnet_id = local.database_subnet_id
  vpc_security_group_ids = [local.mongodb_sg_id]
 

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-mongodb"
    }
  )
    
}

# after creating instance it will trigger
resource "terraform_data" "mongodb" {
  triggers_replace = [
    aws_instance.mongodb.id 
  ]
# copies files
  provisioner "file" {
    source = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  connection {
    type = "ssh"
    user = "ec2-user"
    password = "DevOps321"
    host = aws_instance.mongodb.private_ip
  }

  provisioner "remote-exec" {
    inline = [ 
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh mongodb ${var.environment}"

     ]
  }
}

# redis

resource "aws_instance" "redis" {
  ami = local.ami_id
  instance_type = "t3.micro"
   # what if i doesn't mention subnet a) it will create in default vpc in default subnet
  subnet_id = local.database_subnet_id
  vpc_security_group_ids = [local.redis_sg_id]
 

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-redis"
    }
  )
    
}

# after creating instance it will trigger
resource "terraform_data" "redis" {
  triggers_replace = [
    aws_instance.redis.id 
  ]
# copies files
  provisioner "file" {
    source = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  connection {
    type = "ssh"
    user = "ec2-user"
    password = "DevOps321"
    host = aws_instance.redis.private_ip
  }

  provisioner "remote-exec" {
    inline = [ 
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh redis ${var.environment}"

     ]
  }
}

# mysql

resource "aws_instance" "mysql" {
  ami = local.ami_id
  instance_type = "t3.micro"
   # what if i doesn't mention subnet a) it will create in default vpc in default subnet
  subnet_id = local.database_subnet_id
  iam_instance_profile = "EC2_role_To_fetch_ssmparameter"
  vpc_security_group_ids = [local.mysql_sg_id]
 

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-mysql"
    }
  )
    
}

# after creating instance it will trigger
resource "terraform_data" "mysql" {
  triggers_replace = [
    aws_instance.mysql.id 
  ]
# copies files
  provisioner "file" {
    source = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  connection {
    type = "ssh"
    user = "ec2-user"
    password = "DevOps321"
    host = aws_instance.mysql.private_ip
  }

  provisioner "remote-exec" {
    inline = [ 
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh mysql ${var.environment}"

     ]
  }
}


# rabbitmq

resource "aws_instance" "rabbitmq" {
  ami = local.ami_id
  instance_type = "t3.micro"
   # what if i doesn't mention subnet a) it will create in default vpc in default subnet
  subnet_id = local.database_subnet_id
  vpc_security_group_ids = [local.rabbitmq_sg_id]
 

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-rabbitmq"
    }
  )
    
}

# after creating instance it will trigger
resource "terraform_data" "rabbitmq" {
  triggers_replace = [
    aws_instance.rabbitmq.id 
  ]
# copies files
  provisioner "file" {
    source = "bootstrap.sh"
    destination = "/tmp/bootstrap.sh"
  }

  connection {
    type = "ssh"
    user = "ec2-user"
    password = "DevOps321"
    host = aws_instance.rabbitmq.private_ip
  }

  provisioner "remote-exec" {
    inline = [ 
      "chmod +x /tmp/bootstrap.sh",
      "sudo sh /tmp/bootstrap.sh rabbitmq ${var.environment}"

     ]
  }
}

resource "aws_route53_record" "mongodb" {
  zone_id = var.zone_id
  name = "mongodb-${var.environment}.${var.zone_name}"
  type = "A"
  ttl = 1
  records = [aws_instance.mongodb.private_ip]
}

resource "aws_route53_record" "reddis" {
  zone_id = var.zone_id
  name = "reddis-${var.environment}.${var.zone_name}"
  type = "A"
  ttl = 1
  records = [aws_instance.redis.private_ip]
}

resource "aws_route53_record" "mysql" {
  zone_id = var.zone_id
  name = "mysql-${var.environment}.${var.zone_name}"
  type = "A"
  ttl = 1
  records = [aws_instance.mysql.private_ip]
}

resource "aws_route53_record" "rabbitmq" {
  zone_id = var.zone_id
  name = "rabbitmq-${var.environment}.${var.zone_name}"
  type = "A"
  ttl = 1
  records = [aws_instance.rabbitmq.private_ip]
}
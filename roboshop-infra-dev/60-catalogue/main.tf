resource "aws_alb_target_group" "catalogue" {
  name = "${var.project}-${var.environment}-catalogue"
  port = 8080
  protocol = "HTTP"
  vpc_id = local.vpc_id
  deregistration_delay = 120

  health_check {
    healthy_threshold = 2
    interval = 5
    matcher = "200-299"
    path = "/health" # for every backend there is path known as helath whenever we hits on health it will check healthy or not
    port = 8080
    timeout = 2
    unhealthy_threshold = 5

  }
}

# create catalogue instance

resource "aws_instance" "catalogue" {
  ami = local.ami_id
  instance_type = "t3.micro"
   # what if i doesn't mention subnet a) it will create in default vpc in default subnet
subnet_id  = local.private_subnet_id
  vpc_security_group_ids = [local.catalogue_sg_id]
 

  tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}-catalogue"
    }
  )
    
}

resource "terraform_data" "catalogue" {
  triggers_replace = [
    aws_instance.catalogue.id 
  ]
# copies files
  provisioner "file" {
    source = "catalogue.sh"
    destination = "/tmp/catalogue.sh"
  }

  connection {
    type = "ssh"
    user = "ec2-user"
    password = "DevOps321"
    host = aws_instance.catalogue.private_ip
  }

  provisioner "remote-exec" {
    inline = [ 
      "chmod +x /tmp/catalogue.sh",
      "sudo sh /tmp/catalogue.sh catalogue ${var.environment}"

     ]
  }
}

# instance stop
resource "aws_ec2_instance_state" "catalogue" {
  instance_id = aws_instance.catalogue.id
  state = "stopped"
  depends_on = [ terraform_data.catalogue ] 
}

# aws ami from instance

resource "aws_ami_from_instance" "catalogue" {
  name = "${var.project}-${var.environment}-catalogue"
  source_instance_id = aws_instance.catalogue.id
  depends_on = [ aws_ec2_instance_state.catalogue ]
}

# delete instance

resource "terraform_data" "catalogue_delete" {
  triggers_replace = [
    aws_instance.catalogue.id 
  ]

  # make sure you have aws config in your laptop
  provisioner "local-exec" {
   command = "aws ec2 terminate-instances --instance-ids ${aws_instance.catalogue.id}"
  }

  depends_on = [ aws_ami_from_instance.catalogue ]
}


# launch template

resource "aws_launch_template" "catalogue" {
  name = "${var.project}-${var.environment}-catalogue"

  image_id = aws_ami_from_instance.catalogue.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t2.micro"
  vpc_security_group_ids = [local.catalogue_sg_id]
  update_default_version = true  # each time you update, new version will become default 

# Ec2 tags created by ASG
  tag_specifications {
    resource_type = "instance"

    tags = merge(
      local.common_tags,
      {
        Name = "${var.project}-${var.environment}-catalogue"
      }
    )
  }

# volume tags created by ASG
  tag_specifications {
  resource_type = "volume"
  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-catalogue"
    }

  )
}
# launch template tags
tags = merge(
  local.common_tags,
  {
    Name = "${var.project}-${var.environment}-catalogue"
  }
)

}

resource "aws_autoscaling_group" "catalogue" {
   name = "${var.project}-${var.environment}-catalogue"
  desired_capacity   = 1
  max_size           = 10
  min_size           = 1
  target_group_arns = [aws_alb_target_group.catalogue.arn]
  vpc_zone_identifier = local.private_subnet_ids
  health_check_grace_period = 90  # after 90 sec instance will start 
  health_check_type = "ELB"

  launch_template {
    id      = aws_launch_template.catalogue.id
    version = aws_launch_template.catalogue.latest_version
  }

  dynamic "tag" {
    for_each = merge(
      local.common_tags,
      {
        Name = "${var.project}-${var.environment}-catalogue"
      }
    )
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
    
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }
 
  timeouts {
  
  delete = "15m"
  
  }
}

resource "aws_autoscaling_policy" "catalogue" {
  name = "${var.project}-${var.environment}-catalogue"
  autoscaling_group_name = aws_autoscaling_group.catalogue.name
  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 75.0
  }
}

resource "aws_lb_listener_rule" "catalogue" {
  listener_arn = local.backend_alb_listner_arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.catalogue.arn
  }

  condition {
    host_header {
      values = ["catalogue.backend-${var.environment}.${var.zone_name}"]
    }
  }
}








#creating AWS launch template
resource "aws_launch_template" "vprofile-lauch-template" {
    name = "vprofile-lauch-template"
    image_id = "${var.launch-template-ami}"
    instance_type = "t2.micro"
    key_name = "mamatha-aws-keypair"
    vpc_security_group_ids = [aws_security_group.SG-appserver.id]
    iam_instance_profile {
        name = "${aws_iam_instance_profile.vprofile-instance-profile.name}"
    }
     tag_specifications {
    resource_type = "instance"
  

    tags = {
        Environment = "${var.environment}"
    }
  }

tags = {
    Name = "vprofile-lauch-template"
    Environment = "${var.environment}"
  }  
}
#creating autoscaling group
resource "aws_autoscaling_group" "vprofile-asg" {
  name                      = "vprofile-asg"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 3
  force_delete              = true
  vpc_zone_identifier       = [aws_subnet.public_subnet_2a.id,aws_subnet.public_subnet_2b.id]
  target_group_arns = [aws_lb_target_group.vprofile-targetgroup.arn]
  launch_template {
    id      = aws_launch_template.vprofile-lauch-template.id
    version = aws_launch_template.vprofile-lauch-template.latest_version
  }
 
    
}
#adding autoscaling policy in AWS
resource "aws_autoscaling_policy" "vprofile-asg-policy" {
    name = "vprofile-asg-policy"
    policy_type = "TargetTrackingScaling"
    autoscaling_group_name = aws_autoscaling_group.vprofile-asg.name
    estimated_instance_warmup = 300
    target_tracking_configuration {
      predefined_metric_specification {
        predefined_metric_type = "ASGAverageCPUUtilization"
      }
      target_value = 25.0

    }
  
}

  

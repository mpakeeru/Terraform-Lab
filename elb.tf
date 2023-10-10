#creating target group for LB
resource "aws_lb_target_group" "vprofile-targetgroup" {
    name = "vprofile-targetgroup"
    vpc_id = aws_vpc.main.id
    port = 8080
    protocol = "HTTP"
    slow_start = 0
    health_check {
      enabled = true
      port = 8080
      interval = 30
      protocol = "HTTP"
      path = "/index.html"
      matcher = "200"
      healthy_threshold = 3
      unhealthy_threshold = 3
    }
  tags = {
    Name = "vprofile-targetgroup"
    Environment = "${var.environment}"
  }
}
#attaching an instance to targetgroup
resource "aws_lb_target_group_attachment" "vprofile-targetgroup" {
    target_group_arn = aws_lb_target_group.vprofile-targetgroup.arn
    target_id = aws_instance.vprofile-appserver.id
    port = 8080

  
}
#creating loadbalancer
resource "aws_lb" "vprofile-lb" {
    name = "vprofile-lb"
    internal = false
    load_balancer_type = "application"
    security_groups = [aws_security_group.SG-elb.id]
    subnets = [
        aws_subnet.public_subnet_2a.id,
        aws_subnet.public_subnet_2b.id
    ]
  
}

#creating AWS Listner
resource "aws_lb_listener" "vprofile-http" {
    load_balancer_arn = aws_lb.vprofile-lb.arn
    port = "80"
    protocol = "HTTP"
    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.vprofile-targetgroup.arn
    }
  
}
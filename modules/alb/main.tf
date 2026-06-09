resource "aws_lb" "alb" {

  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [var.alb_sg_id]

  subnets = var.public_subnet_ids

  tags = {
    Name = "web-alb"
  }
}
resource "aws_lb_target_group" "tg" {

  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"

  vpc_id = var.vpc_id

  health_check {

    path = "/"

    interval = 30

    healthy_threshold = 3

    unhealthy_threshold = 3

    timeout = 5

    matcher = "200"
  }

  tags = {
    Name = "web-target-group"
  }
}


resource "aws_lb_listener" "http" {

  load_balancer_arn = aws_lb.alb.arn

  port = 80

  protocol = "HTTP"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.tg.arn
  }
}


resource "aws_autoscaling_group" "asg" {

  desired_capacity = 2

  max_size = 3

  min_size = 2

  vpc_zone_identifier = var.private_subnet_ids

  target_group_arns = [
    var.target_group_arn
  ]

  launch_template {

    id = var.launch_template_id

    version = "$Latest"
  }

  health_check_type = "ELB"

  tag {

    key = "Name"

    value = "asg-instance"

    propagate_at_launch = true
  }
}
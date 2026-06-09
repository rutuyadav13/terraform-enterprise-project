resource "aws_autoscaling_policy" "scale_out" {

  name = "scale-out-policy"

  autoscaling_group_name = var.asg_name

  adjustment_type = "ChangeInCapacity"

  scaling_adjustment = 1

  cooldown = 300
}

resource "aws_autoscaling_policy" "scale_in" {

  name = "scale-in-policy"

  autoscaling_group_name = var.asg_name

  adjustment_type = "ChangeInCapacity"

  scaling_adjustment = -1

  cooldown = 300
}
resource "aws_cloudwatch_metric_alarm" "high_cpu" {

  alarm_name = "high-cpu"

  comparison_operator = "GreaterThanThreshold"

  evaluation_periods = 2

  metric_name = "CPUUtilization"

  namespace = "AWS/EC2"

  period = 120

  statistic = "Average"

  threshold = 70

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_actions = [
    aws_autoscaling_policy.scale_out.arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "low_cpu" {

  alarm_name = "low-cpu"

  comparison_operator = "LessThanThreshold"

  evaluation_periods = 2

  metric_name = "CPUUtilization"

  namespace = "AWS/EC2"

  period = 120

  statistic = "Average"

  threshold = 30

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_actions = [
    aws_autoscaling_policy.scale_in.arn
  ]
}

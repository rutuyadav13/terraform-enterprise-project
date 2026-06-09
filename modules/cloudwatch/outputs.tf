output "high_cpu_alarm" {
  value = aws_cloudwatch_metric_alarm.high_cpu.id
}

output "low_cpu_alarm" {
  value = aws_cloudwatch_metric_alarm.low_cpu.id
}
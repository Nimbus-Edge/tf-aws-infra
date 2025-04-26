resource "aws_cloudwatch_metric_alarm" "cw_alarm" {
  alarm_name          = var.name
  comparison_operator = var.comparison_operator
  evaluation_periods  = 2
  metric_name         = var.metric_name
  namespace           = var.namespace
  period              = var.period
  statistic           = var.statistic
  threshold           = var.threshold
  alarm_actions       = var.alarm_actions

  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }
}

// Create SNS topic for auto scaling groups in eks
resource "aws_sns_topic" "asg-alarms" {
  name = var.asg_sns_topic_name
}

// Subscription for SNS topic - sends notifications to the specified email
resource "aws_sns_topic_subscription" "asg_alarms_email" {
  topic_arn = aws_sns_topic.asg-alarms.arn
  protocol  = "email"
  endpoint  = var.asg_sns_subscription_email
}

resource "aws_cloudwatch_dashboard" "Node-group-dashboard" {
  dashboard_name = var.asg_cloudwatch_dashboard_name
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 24
        height = 9

        properties = {
          sparkline = true
          view      = "singleValue"
          metrics   = [
            [
              "AWS/EC2",
              "CPUUtilization",
              "AutoScalingGroupName",
              "${data.aws_eks_node_group.pokemon.resources[0].autoscaling_groups[0].name}"
            ],
            [
              "AWS/EC2",
              "DiskReadOps",
              "AutoScalingGroupName",
              "${data.aws_eks_node_group.pokemon.resources[0].autoscaling_groups[0].name}"
            ],
            [
              "AWS/EC2",
              "NetworkPacketsOut",
              "AutoScalingGroupName",
              "${data.aws_eks_node_group.pokemon.resources[0].autoscaling_groups[0].name}"
            ],
            [
              "AWS/EC2",
              "DiskWriteBytes",
              "AutoScalingGroupName",
              "${data.aws_eks_node_group.pokemon.resources[0].autoscaling_groups[0].name}"
            ],
            [
              "AWS/EC2",
              "StatusCheckFailed_Instance",
              "AutoScalingGroupName",
              "${data.aws_eks_node_group.pokemon.resources[0].autoscaling_groups[0].name}"
            ],
            [
              "AWS/EC2",
              "DiskWriteOps",
              "AutoScalingGroupName",
              "${data.aws_eks_node_group.pokemon.resources[0].autoscaling_groups[0].name}"
            ],
            [
              "AWS/EC2",
              "NetworkOut",
              "AutoScalingGroupName",
              "${data.aws_eks_node_group.pokemon.resources[0].autoscaling_groups[0].name}"
            ],
            [
              "AWS/EC2",
              "DiskReadBytes",
              "AutoScalingGroupName",
              "${data.aws_eks_node_group.pokemon.resources[0].autoscaling_groups[0].name}"
            ],
            [
              "AWS/EC2",
              "NetworkPacketsIn",
              "AutoScalingGroupName",
              "${data.aws_eks_node_group.pokemon.resources[0].autoscaling_groups[0].name}"
            ],
            [
              "AWS/EC2",
              "NetworkIn",
              "AutoScalingGroupName",
              "${data.aws_eks_node_group.pokemon.resources[0].autoscaling_groups[0].name}"
            ]
          ]
          region = "${var.aws_region}"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_metric_alarm" "ASG_CPUUtilization" {
  alarm_name          = var.asg_cloudwatch_alarm_name
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1" // Number of consecutive periods for which the metric condition must be true
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "60"      // in seconds
  statistic           = "Average" // metric aggregation type
  threshold           = "25"      // threshold for triggering the alarm (75% CPU utilization)
  alarm_description   = "This alarm monitors ASG CPU utilization"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.asg-alarms.arn] // Action to trigger SNS notification
  dimensions = {
    AutoScalingGroupName = "${data.aws_eks_node_group.pokemon.resources[0].autoscaling_groups[0].name}"
  }
}
resource "aws_cloudwatch_dashboard" "Node-line-graph" {
  dashboard_name = var.node_line_graph_dashboard_name

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 4

        properties = {
          title    = "CPU Utilization"
          sparkline = true
          metrics   = [
            [
              "AWS/EC2",
              "CPUUtilization",
              "AutoScalingGroupName",
              "${data.aws_eks_node_group.pokemon.resources[0].autoscaling_groups[0].name}"
            ]
          ]
          region = "${var.aws_region}"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 5
        width  = 12
        height = 4

        properties = {
          title    = "CPU Credit Balance"
          sparkline = true
          metrics   = [
            [
              "AWS/EC2",
              "CPUCreditBalance",
              "AutoScalingGroupName",
              "${data.aws_eks_node_group.pokemon.resources[0].autoscaling_groups[0].name}"
            ]
          ]
          region = "${var.aws_region}"
        }
      }
    ]
  })
}


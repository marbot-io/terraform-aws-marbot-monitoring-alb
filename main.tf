terraform {
  required_version = ">= 0.12.0"
  required_providers {
    aws    = ">= 2.48.0"
    random = ">= 2.2"
  }
}

data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  topic_arn = var.create_topic == false ? var.topic_arn : join("", aws_sns_topic.marbot.*.arn)
}

##########################################################################
#                                                                        #
#                                 TOPIC                                  #
#                                                                        #
##########################################################################

resource "aws_sns_topic" "marbot" {
  count = (var.create_topic && var.enabled) ? 1 : 0

  name_prefix = "marbot"
  tags        = var.tags
}

resource "aws_sns_topic_policy" "marbot" {
  count = (var.create_topic && var.enabled) ? 1 : 0

  arn    = join("", aws_sns_topic.marbot.*.arn)
  policy = data.aws_iam_policy_document.topic_policy.json
}

data "aws_iam_policy_document" "topic_policy" {
  statement {
    sid       = "Sid1"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [join("", aws_sns_topic.marbot.*.arn)]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
      ]
    }
  }

  statement {
    sid       = "Sid2"
    effect    = "Allow"
    actions   = ["sns:Publish"]
    resources = [join("", aws_sns_topic.marbot.*.arn)]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_sns_topic_subscription" "marbot" {
  depends_on = [aws_sns_topic_policy.marbot]
  count      = (var.create_topic && var.enabled) ? 1 : 0

  topic_arn              = join("", aws_sns_topic.marbot.*.arn)
  protocol               = "https"
  endpoint               = "https://api.marbot.io/${var.stage}/endpoint/${var.endpoint_id}"
  endpoint_auto_confirms = true
  delivery_policy        = <<JSON
{
  "healthyRetryPolicy": {
    "minDelayTarget": 1,
    "maxDelayTarget": 60,
    "numRetries": 100,
    "numNoDelayRetries": 0,
    "backoffFunction": "exponential"
  },
  "throttlePolicy": {
    "maxReceivesPerSecond": 1
  }
}
JSON
}

resource "aws_cloudwatch_event_rule" "monitoring_jump_start_connection" {
  depends_on = [aws_sns_topic_subscription.marbot]
  count      = (var.module_version_monitoring_enabled && var.enabled) ? 1 : 0

  name                = "marbot-alb-connection-${random_id.id8.hex}"
  description         = "Monitoring Jump Start connection. (created by marbot)"
  schedule_expression = "rate(30 days)"
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "monitoring_jump_start_connection" {
  count = (var.module_version_monitoring_enabled && var.enabled) ? 1 : 0

  rule      = join("", aws_cloudwatch_event_rule.monitoring_jump_start_connection.*.name)
  target_id = "marbot"
  arn       = local.topic_arn
  input     = <<JSON
{
  "Type": "monitoring-jump-start-tf-connection",
  "Module": "alb",
  "Version": "1.2.0",
  "Partition": "${data.aws_partition.current.partition}",
  "AccountId": "${data.aws_caller_identity.current.account_id}",
  "Region": "${data.aws_region.current.name}"
}
JSON
}

##########################################################################
#                                                                        #
#                                 ALARMS                                 #
#                                                                        #
##########################################################################

resource "random_id" "id8" {
  byte_length = 8
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx_count_too_high" {
  depends_on = [aws_sns_topic_subscription.marbot]
  count      = (var.alb_5xx_count == "static" && var.enabled) ? 1 : 0

  alarm_name          = "marbot-alb-5xx-count-too-high-${random_id.id8.hex}"
  alarm_description   = "Number of 5XX responses from ALB too high. (created by marbot)"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  statistic           = "Sum"
  period              = var.alb_5xx_count_period
  evaluation_periods  = var.alb_5xx_count_evaluation_periods
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.alb_5xx_count_threshold
  alarm_actions       = [local.topic_arn]
  ok_actions          = [local.topic_arn]
  dimensions = {
    LoadBalancer = var.loadbalancer_fullname
  }
  treat_missing_data = "notBreaching"
  tags               = var.tags
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx_count_too_high_anomaly_detection" {
  depends_on = [aws_sns_topic_subscription.marbot]
  count      = (var.alb_5xx_count == "anomaly_detection" && var.enabled) ? 1 : 0

  alarm_name          = "marbot-alb-5xx-count-too-high-${random_id.id8.hex}"
  alarm_description   = "Number of 5XX responses from ALB unexpected. (created by marbot)"
  evaluation_periods  = var.alb_5xx_count_evaluation_periods
  comparison_operator = "GreaterThanUpperThreshold"
  threshold_metric_id = "e1"
  alarm_actions       = [local.topic_arn]
  ok_actions          = [local.topic_arn]
  treat_missing_data  = "notBreaching"
  tags                = var.tags

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1)"
    label       = "HTTPCode_ELB_5XX_Count (expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "HTTPCode_ELB_5XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = var.alb_5xx_count_period
      stat        = "Sum"

      dimensions = {
        LoadBalancer = var.loadbalancer_fullname
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_5xx_rate_too_high" {
  depends_on = [aws_sns_topic_subscription.marbot]
  count      = (var.alb_5xx_rate == "static" && var.enabled) ? 1 : 0

  alarm_name          = "marbot-alb-5xx-rate-too-high-${random_id.id8.hex}"
  alarm_description   = "5XX responses relativ to request from ALB too high. (created by marbot)"
  evaluation_periods  = var.alb_5xx_rate_evaluation_periods
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.alb_5xx_rate_threshold
  alarm_actions       = [local.topic_arn]
  ok_actions          = [local.topic_arn]
  treat_missing_data  = "notBreaching"
  tags                = var.tags

  metric_query {
    id          = "alb5xx" # must start with [a-z]
    return_data = "false"
    metric {
      metric_name = "HTTPCode_ELB_5XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = var.alb_5xx_rate_period
      stat        = "Sum"

      dimensions = {
        LoadBalancer = var.loadbalancer_fullname
      }
    }
  }

  metric_query {
    id          = "requests"
    return_data = "false"
    metric {
      metric_name = "RequestCount"
      namespace   = "AWS/ApplicationELB"
      period      = var.alb_5xx_rate_period
      stat        = "Sum"

      dimensions = {
        LoadBalancer = var.loadbalancer_fullname
      }
    }
  }

  metric_query {
    id          = "rate"
    expression  = "IF(requests<10, 0, alb5xx/requests)"
    label       = "5XX rate"
    return_data = "true"
  }
}

resource "aws_cloudwatch_metric_alarm" "alb_rejected_connection_count_too_high" {
  depends_on = [aws_sns_topic_subscription.marbot]
  count      = (var.alb_rejected_connection_count == "static" && var.enabled) ? 1 : 0

  alarm_name          = "marbot-alb-rejected-connection-count-too-high-${random_id.id8.hex}"
  alarm_description   = "Number of rejected connections by ALB too high, ALB needs time to scale up. (created by marbot)"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "RejectedConnectionCount"
  statistic           = "Sum"
  period              = var.alb_rejected_connection_count_period
  evaluation_periods  = var.alb_rejected_connection_count_evaluation_periods
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.alb_rejected_connection_count_threshold
  alarm_actions       = [local.topic_arn]
  ok_actions          = [local.topic_arn]
  dimensions = {
    LoadBalancer = var.loadbalancer_fullname
  }
  treat_missing_data = "notBreaching"
  tags               = var.tags
}

resource "aws_cloudwatch_metric_alarm" "target_5xx_count_too_high" {
  depends_on = [aws_sns_topic_subscription.marbot]
  count      = (var.target_5xx_count == "static" && var.enabled) ? 1 : 0

  alarm_name          = "marbot-target-5xx-count-too-high-${random_id.id8.hex}"
  alarm_description   = "Number of 5XX responses from targets too high. (created by marbot)"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_Target_5XX_Count"
  statistic           = "Sum"
  period              = var.target_5xx_count_period
  evaluation_periods  = var.target_5xx_count_evaluation_periods
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.target_5xx_count_threshold
  alarm_actions       = [local.topic_arn]
  ok_actions          = [local.topic_arn]
  dimensions = {
    LoadBalancer = var.loadbalancer_fullname
    TargetGroup  = var.targetgroup_fullname
  }
  treat_missing_data = "notBreaching"
  tags               = var.tags
}

resource "aws_cloudwatch_metric_alarm" "target_5xx_count_too_high_anomaly_detection" {
  depends_on = [aws_sns_topic_subscription.marbot]
  count      = (var.target_5xx_count == "anomaly_detection" && var.enabled) ? 1 : 0

  alarm_name          = "marbot-target-5xx-count-too-high-${random_id.id8.hex}"
  alarm_description   = "Number of 5XX responses from targets unexpected. (created by marbot)"
  evaluation_periods  = var.target_5xx_count_evaluation_periods
  comparison_operator = "GreaterThanUpperThreshold"
  threshold_metric_id = "e1"
  alarm_actions       = [local.topic_arn]
  ok_actions          = [local.topic_arn]
  treat_missing_data  = "notBreaching"
  tags                = var.tags

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1)"
    label       = "HTTPCode_Target_5XX_Count (expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "HTTPCode_Target_5XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = var.target_5xx_count_period
      stat        = "Sum"

      dimensions = {
        LoadBalancer = var.loadbalancer_fullname
        TargetGroup  = var.targetgroup_fullname
      }
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "target_connection_error_count_too_high" {
  depends_on = [aws_sns_topic_subscription.marbot]
  count      = (var.target_connection_error_count == "static" && var.enabled) ? 1 : 0

  alarm_name          = "marbot-target-connection-error-count-too-high-${random_id.id8.hex}"
  alarm_description   = "Number of rejected connections from ALB to targets too high. (created by marbot)"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "TargetConnectionErrorCount"
  statistic           = "Sum"
  period              = var.target_connection_error_count_period
  evaluation_periods  = var.target_connection_error_count_evaluation_periods
  comparison_operator = "GreaterThanThreshold"
  threshold           = var.target_connection_error_count_threshold
  alarm_actions       = [local.topic_arn]
  ok_actions          = [local.topic_arn]
  dimensions = {
    LoadBalancer = var.loadbalancer_fullname
    TargetGroup  = var.targetgroup_fullname
  }
  treat_missing_data = "notBreaching"
  tags               = var.tags
}

# We can not only check the var.topic_arn !="" because of the Terraform error:  The "count" value depends on resource attributes that cannot be determined until apply, so Terraform cannot predict how many instances will be created.
variable "create_topic" {
  type        = bool
  description = "Create SNS topic? If set to false you must set topic_arn as well!"
  default     = true
}

variable "topic_arn" {
  type        = string
  description = "Optional SNS topic ARN if create_topic := false (usually the output of the modules marbot-monitoring-basic or marbot-standalone-topic)."
  default     = ""
}

variable "stage" {
  type        = string
  description = "marbot stage (never change this!)."
  default     = "v1"
}

variable "endpoint_id" {
  type        = string
  description = "Your marbot endpoint ID (to get this value: select a channel where marbot belongs to and send a message like this: \"@marbot show me my endpoint id\")."
}

variable "enabled" {
  type        = bool
  description = "Turn the module on or off"
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "loadbalancer_fullname" {
  type        = string
  description = "The full name of the load balancer (last part of ARN, e.g., app/load-balancer-name/1234567890123456)."
}

variable "targetgroup_fullname" {
  type        = string
  description = "The full name of the target group (last part of ARN, e.g., targetgroup/target-group-name/1234567890123456)."
}



variable "alb_5xx_count" {
  type        = string
  description = "5XX responses from the ALB (not the targets) (static|anomaly_detection|off)."
  default     = "static"
}

variable "alb_5xx_count_threshold" {
  type        = number
  description = "The maximum number of 5XX responses from the ALB, not the targets (>= 0)."
  default     = 0
}

variable "alb_5xx_count_period" {
  type        = number
  description = "The period in seconds over which the specified statistic is applied (<= 86400 and multiple of 60)."
  default     = 60
}

variable "alb_5xx_count_evaluation_periods" {
  type        = number
  description = "The number of periods over which data is compared to the specified threshold (>= 1 and $period*$evaluation_periods <= 86400)."
  default     = 1
}



variable "alb_5xx_rate" {
  type        = string
  description = "5XX responses from the ALB relativ to requests (static|off)."
  default     = "off"
}

variable "alb_5xx_rate_threshold" {
  type        = number
  description = "The maximum rate (in %) of 5XX responses from the ALB (0-100)."
  default     = 5
}

variable "alb_5xx_rate_period" {
  type        = number
  description = "The period in seconds over which the specified statistic is applied (<= 86400 and multiple of 60)."
  default     = 300
}

variable "alb_5xx_rate_evaluation_periods" {
  type        = number
  description = "The number of periods over which data is compared to the specified threshold (>= 1 and $period*$evaluation_periods <= 86400)."
  default     = 1
}



variable "alb_rejected_connection_count" {
  type        = string
  description = "Rejected connections because the ALB had reached its maximum number of connections (static|off)."
  default     = "static"
}

variable "alb_rejected_connection_count_threshold" {
  type        = number
  description = "The maximum number of connections (>= 0)."
  default     = 0
}

variable "alb_rejected_connection_count_period" {
  type        = number
  description = "The period in seconds over which the specified statistic is applied (<= 86400 and multiple of 60)."
  default     = 60
}

variable "alb_rejected_connection_count_evaluation_periods" {
  type        = number
  description = "The number of periods over which data is compared to the specified threshold (>= 1 and $period*$evaluation_periods <= 86400)."
  default     = 1
}



variable "target_5xx_count" {
  type        = string
  description = "5XX responses from the targets (static|anomaly_detection|off)."
  default     = "static"
}

variable "target_5xx_count_threshold" {
  type        = number
  description = "The maximum number of 5XX responses from the targets (>= 0)."
  default     = 0
}

variable "target_5xx_count_period" {
  type        = number
  description = "The period in seconds over which the specified statistic is applied (<= 86400 and multiple of 60)."
  default     = 60
}

variable "target_5xx_count_evaluation_periods" {
  type        = number
  description = "The number of periods over which data is compared to the specified threshold (>= 1 and $period*$evaluation_periods <= 86400)."
  default     = 1
}



variable "target_connection_error_count" {
  type        = string
  description = "5XX responses from the targets (static|off)."
  default     = "static"
}

variable "target_connection_error_count_threshold" {
  type        = number
  description = "The maximum number of connection errors from the ALB to the targets (>= 0)."
  default     = 0
}

variable "target_connection_error_count_period" {
  type        = number
  description = "The period in seconds over which the specified statistic is applied (<= 86400 and multiple of 60)."
  default     = 60
}

variable "target_connection_error_count_evaluation_periods" {
  type        = number
  description = "The number of periods over which data is compared to the specified threshold (>= 1 and $period*$evaluation_periods <= 86400)."
  default     = 1
}

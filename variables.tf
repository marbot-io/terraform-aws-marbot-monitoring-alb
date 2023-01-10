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

variable "alb_5xx_count_threshold" {
  type        = number
  description = "The maximum number of 5XX responses from the ALB (not the targets) (set to -1 to disable)."
  default     = 0
}

variable "alb_rejected_connection_count_threshold" {
  type        = number
  description = "The maximum number of connections that were rejected because the ALB had reached its maximum number of connections (set -1 to disable)."
  default     = 0
}

variable "target_5xx_count_threshold" {
  type        = number
  description = "The maximum number of 5XX responses from the targets (set -1 to disable)."
  default     = 0
}

variable "target_connection_error_count_threshold" {
  type        = number
  description = "The maximum number of connection errors from the ALB to the targets (set -1 to disable)."
  default     = 0
}

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

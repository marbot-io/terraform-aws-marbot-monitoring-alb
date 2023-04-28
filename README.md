# Application Load Balancer (ALB) monitoring

Creates CloudWatch alarms to monitor an Application Load Balancer and forwards alarms to Slack or Microsoft Teams managed by [marbot](https://marbot.io/).

## Usage

1. Create a new directory
2. Within the new directory, create a file `main.tf` with the following content:
```
provider "aws" {}

module "marbot-monitoring-alb" {
  source   = "marbot-io/marbot-monitoring-alb/aws"
  #version = "x.y.z"         # we recommend to pin the version

  endpoint_id              = "" # to get this value, select a channel where marbot belongs to and send a message like this: "@marbot show me my endpoint id"
  loadbalancer_fullname    = "" # the full name of the load balancer
  targetgroup_fullname     = "" # the full name of the target group
}
```
3. Run the following commands:
```
terraform init
terraform apply
```

## Config via tags

You can also configure this module by tagging the ALB (required v1.3.0 or higher). Tags take precedence over variables (tags override variables).

| tag key                                                   | default value                                               | allowed values                                        |
| --------------------------------------------------------- | ----------------------------------------------------------- | ----------------------------------------------------- |
| `marbot`                                                  | on                                                          | on|off                                                |
| `marbot:alb-5xx-count`                                    | variable `alb_5xx_count`                                    | static|anomaly_detection|off                          |
| `marbot:alb-5xx-count:threshold`                          | variable `alb_5xx_count_threshold`                          | >= 0                                                  |
| `marbot:alb-5xx-count:period`                             | variable `alb_5xx_count_period`                             | <= 86400 and multiple of 60                           |
| `marbot:alb-5xx-count:evaluation-periods`                 | variable `alb_5xx_count_evaluation_periods`                 | >= 1 and $period*$evaluation-periods <= 86400         |
| `marbot:alb-5xx-rate`                                     | variable `alb_5xx_rate`                                     | static|off                                            |
| `marbot:alb-5xx-rate:threshold`                           | variable `alb_5xx_rate_threshold`                           | 0-100                                                 |
| `marbot:alb-5xx-rate:period`                              | variable `alb_5xx_rate_period`                              | <= 86400 and multiple of 60                           |
| `marbot:alb-5xx-rate:evaluation-periods`                  | variable `alb_5xx_rate_evaluation_periods`                  | >= 1 and $period*$evaluation-periods <= 86400         |
| `marbot:alb-rejected-connection-count`                    | variable `alb_rejected_connection_count`                    | static|off                                            |
| `marbot:alb-rejected-connection-count:threshold`          | variable `alb_rejected_connection_count_threshold`          | >= 0                                                  |
| `marbot:alb-rejected-connection-count:period`             | variable `alb_rejected_connection_count_period`             | <= 86400 and multiple of 60                           |
| `marbot:alb-rejected-connection-count:evaluation-periods` | variable `alb_rejected_connection_count_evaluation_periods` | >= 1 and $period*$evaluation-periods <= 86400         |
| `marbot:target-5xx-count`                                 | variable `target_5xx_count`                                 | static|anomaly_detection|off                          |
| `marbot:target-5xx-count:threshold`                       | variable `target_5xx_count_threshold`                       | >= 0                                                  |
| `marbot:target-5xx-count:period`                          | variable `target_5xx_count_period`                          | <= 86400 and multiple of 60                           |
| `marbot:target-5xx-count:evaluation-periods`              | variable `target_5xx_count_evaluation_periods`              | >= 1 and $period*$evaluation-periods <= 86400         |
| `marbot:target-connection-error-count`                    | variable `target_connection_error_count`                    | static|off                                            |
| `marbot:target-connection-error-count:threshold`          | variable `target_connection_error_count_threshold`          | >= 0                                                  |
| `marbot:target-connection-error-count:period`             | variable `target_connection_error_count_period`             | <= 86400 and multiple of 60                           |
| `marbot:target-connection-error-count:evaluation-periods` | variable `target_connection_error_count_evaluation_periods` | >= 1 and $period*$evaluation-periods <= 86400         |

## Update procedure

1. Update the `version`
2. Run the following commands:
```
terraform get
terraform apply
```

## License
All modules are published under Apache License Version 2.0.

## About
A [marbot.io](https://marbot.io/) project. Engineered by [widdix](https://widdix.net).

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.56.0"
    }
  }
}

module "marbot-monitoring-alb" {
  source = "../../"

  endpoint_id           = var.endpoint_id
  loadbalancer_fullname = var.loadbalancer_fullname
  targetgroup_fullname  = var.targetgroup_fullname
}
output "loadbalancer_fullname" {
  value = aws_lb.default.arn_suffix
}

output "targetgroup_fullname" {
  value = aws_lb_target_group.default.arn_suffix
}

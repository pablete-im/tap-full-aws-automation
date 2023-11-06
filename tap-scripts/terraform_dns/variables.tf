variable "aws_region" {
  description = "The aws region. https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html"
  type        = string
  default     = "eu-west-1"
}

variable "elb_dns_name" {
  description = "Public DNS name of the AWS Load Balancer."
  type = string
}

variable "elb_zone_id" {
  description = "The canonical hosted zone ID of the ELB (to be used in a Route 53 Alias record)."
  type        = string
}

variable "route53_hosted_zone_id" {
  description = "The ID of the hosted zone to contain this record."
  type        = string
}

variable "full_domain" {
  description = "The full domain for the installed profile, e.g. tap-full.example.com"
  type        = string
}
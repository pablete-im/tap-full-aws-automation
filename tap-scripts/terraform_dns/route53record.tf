# Copyright 2022 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause

# Route53 Alias record
resource "aws_route53_record" "tap_record" {
  zone_id = var.route53_hosted_zone_id
  name    = var.full_domain
  type    = "A"

  alias {
    name                   = var.elb_dns_name
    zone_id                = var.elb_zone_id
    evaluate_target_health = true
  }
}

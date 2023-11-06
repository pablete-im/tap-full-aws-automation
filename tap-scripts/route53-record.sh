#!/bin/bash
# Copyright 2022 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause
source var.conf

export ELB_DNS_NAME=\"$(kubectl get svc -n tanzu-system-ingress envoy -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')\"
export ELB_ZONE_ID=\"$(aws elb describe-load-balancers | jq -r ".LoadBalancerDescriptions[] | select(.DNSName == $ELB_DNS_NAME) | .CanonicalHostedZoneNameID")\"

#replace tap_full_domain by MAIN_FQDN
BASE_DOMAIN=\"$(echo $tap_full_domain | awk -F. '{print $(NF-1)"."$NF}')\"
#export SUBDOMAIN=\"*.$(echo $tap_full_domain | sed 's/\.[^.]*\.[^.]*$//')\"
export FULL_DOMAIN=\"*.${tap_full_domain}\"
export ROUTE53_HOSTED_ZONE_ID=$(aws route53 list-hosted-zones | jq ".HostedZones[] | select(.Name | contains($BASE_DOMAIN)) | .Id")

envsubst < ./terraform_dns/terraform.tfvars.template > ./terraform_dns/terraform.tfvars

cd terraform_dns
terraform init
terraform apply -auto-approve
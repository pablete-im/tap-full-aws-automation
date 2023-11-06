#!/bin/bash
# Copyright 2022 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause
source var.conf

chmod +x tap-full.sh
chmod +x tanzu-cli-setup.sh
chmod +x tap-demo-app-deploy.sh

chmod +x var-input-validatation.sh

./var-input-validatation.sh
echo "Step 1 => installing tanzu cli !!!"
./tanzu-cli-setup.sh
echo "Step 2 => Setup TAP Full Cluster"
./tap-full.sh

echo "Step 3 => Create DNS records in Route53"
./route53-record.sh

echo "Step 4 => Deploy sample app"
./tap-demo-app-deploy.sh


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

echo "pick an external ip from service output and configure DNS wildcard records in your dns server for full cluster"
echo "example full cluster - *.full.customer0.io ==> <ingress external ip/cname>"

echo "Step 5 => Deploy sample app"
./tap-demo-app-deploy.sh
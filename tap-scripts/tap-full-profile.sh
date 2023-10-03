#!/bin/bash
# Copyright 2022 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause
source var.conf

#echo  "Login to Full Cluster !!! "
#login to kubernets eks full cluster
#aws eks --region $aws_region update-kubeconfig --name ${TAP_FULL_CLUSTER_NAME}

# set the following variables
#export TAP_NAMESPACE="tap-install"
export TAP_REGISTRY_USER=$registry_user
export TAP_REGISTRY_SERVER_ORIGINAL=$registry_url
if [ $registry_url = "${DOCKERHUB_REGISTRY_URL}" ]
then
  export TAP_REGISTRY_SERVER=$TAP_REGISTRY_USER
  export TAP_REGISTRY_REPOSITORY=$TAP_REGISTRY_USER
else
  export TAP_REGISTRY_SERVER=$registry_url
  export TAP_REGISTRY_REPOSITORY="supply-chain"
fi
export INSTALL_REGISTRY_USERNAME=$tanzu_net_reg_user
export INSTALL_REGISTRY_PASSWORD=$tanzu_net_reg_password

kubectl apply -f - -o yaml << EOF
apiVersion: v1
kind: Namespace
metadata:
  name: metadata-store
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: metadata-store-read-write-custom
  namespace: metadata-store
rules:
- resources: ["all"]
  verbs: ["get", "create", "update"]
  apiGroups: [ "metadata-store/v1" ]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: metadata-store-read-write-custom
  namespace: metadata-store
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: metadata-store-read-write-custom
subjects:
- kind: ServiceAccount
  name: metadata-store-read-write-client-custom
  namespace: metadata-store
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: metadata-store-read-write-client-custom
  namespace: metadata-store
  annotations:
    kapp.k14s.io/change-group: "metadata-store.apps.tanzu.vmware.com/service-account"
automountServiceAccountToken: false
---
apiVersion: v1
kind: Secret
type: kubernetes.io/service-account-token
metadata:
  name: metadata-store-read-write-client-custom
  namespace: metadata-store
  annotations:
    kapp.k14s.io/change-rule: "upsert after upserting metadata-store.apps.tanzu.vmware.com/service-account"
    kubernetes.io/service-account.name: "metadata-store-read-write-client-custom"
EOF

CLUSTER_TOKEN_FULL=$(kubectl get secret -n metadata-store metadata-store-read-write-client-custom -o jsonpath='{.data.token}' | base64 -d)

cat <<EOF | tee tap-values-full.yaml
profile: full

shared:
  ingress_domain: "${tap_full_domain}" 

ceip_policy_disclosed: true

excluded_packages:
  - policy.apps.tanzu.vmware.com

contour:
  infrastructure_provider: aws
  envoy:
    service:
      type: LoadBalancer

cnrs:
  domain_name: "${tap_full_domain}"

supply_chain: testing_scanning
ootb_supply_chain_testing_scanning: 
  registry:
    server: "${TAP_REGISTRY_SERVER_ORIGINAL}"
    repository: "${TAP_REGISTRY_REPOSITORY}"
  gitops:
    ssh_secret: ""
  cluster_builder: default
  service_account: default

buildservice:
  kp_default_repository: "${TAP_REGISTRY_SERVER}/build-service"
  kp_default_repository_secret:
    name: registry-credentials
    namespace: "${TAP_NAMESPACE}"

grype:
  namespace: "default" 
  targetImagePullSecret: "tap-registry"

scanning:
  metadataStore:
    url: "" # Disable embedded integration since it's deprecated

image_policy_webhook:
  allow_unmatched_images: true

learningcenter:
  ingressDomain: "learning.${tap_full_domain}"
  ingressClass: contour
tap_gui:
  service_type: ClusterIP
  app_config:
    proxy:
      /metadata-store:
        target: https://metadata-store-app.metadata-store:8443/api/v1
        changeOrigin: true
        secure: false
        headers:
          Authorization: "Bearer ${CLUSTER_TOKEN_FULL}"
          X-Custom-Source: project-star
    techdocs:
      builder: 'external'
      publisher:
        type: 'awsS3'
        awsS3:
          bucketName: $tap_gui_docs_bucket
          region: $aws_region
          s3ForcePathStyle: false

    catalog:
      locations:
        - type: url
          target: ${tap_git_catalog_url}
    auth:
      environment: development
      providers:
        github:
          development:
            clientId: "$GITHUB_AUTH_CLIENT_ID"
            clientSecret: "$GITHUB_AUTH_CLIENT_SECRET"
metadata_store:
  app_service_type: LoadBalancer
  ns_for_export_app_cert: "*"

appliveview:
  ingressEnabled: "true"
  sslDeactivated: "true"

EOF

tanzu package install tap -p tap.tanzu.vmware.com -v $TAP_VERSION --values-file tap-values-full.yaml -n "${TAP_NAMESPACE}"
tanzu package installed get tap -n "${TAP_NAMESPACE}"

# ensure all full cluster packages are installed succesfully
tanzu package installed list -A

kubectl get svc -n tanzu-system-ingress

echo "pick external ip from service output  and configure DNS wild card(*) into your DNS server like aws route 53 etc"
echo "example - *.iter.customer0.io ==> <ingress external ip/cname>"
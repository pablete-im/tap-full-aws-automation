## Purpose

This project is designed to build a Tanzu Application Platform 1.6.x single-cluster instance on AWS EKS that corresponds to the [Full TAP profile in the Official VMware Docs](https://docs.vmware.com/en/VMware-Tanzu-Application-Platform/1.6/tap/install-intro.html). 

This is a 2-step automation with minimum inputs into config files. This scripts assume that Tanzu Cluster essentials are already present in the TKG cluster.

* **Step 1** To create all aws resources for tap like VPC, 1 eks cluster and associated security and Iam group, node etc.
* **Step 2** To install TAP full profile into a Tanzu K8S cluster.

Specifically, this automation will build:
- A aws VPC (internet facing)
- 1 EKS cluster named as tap-full and associated security IAM roles and groups and nodes into AWS.
- Install Tanzu Application Platform full profile on the AWS EKS cluster. 
- Install Tanzu Application Platform sample demo app. 

## AWS resources matrix 

 **Resource Name** | **Size/Number**  
 -----|-----
 VPC | 1
 Subnets | 2 private , 2 public
 VPC cidr | 10.0.0.0/16
 EKS clusters | 1
 Nodes per eks cluster | Nodes : 4, Node Size : t2.xlarge , Storage : 100GB disk size
## Prerequisite 

Following cli must be setup into jumbbox or execution machine/terminal. 
   * terraform cli 
   * aws cli 

## Prepare the Environment

First, be sure that your AWS access credentials are available within your environment.

### Set aws env variables.
 
```bash
export AWS_ACCESS_KEY_ID=<your AWS access key>
export AWS_SECRET_ACCESS_KEY=<your AWS secret access key>
export AWS_REGION=us-east-1  # ensure the region is set correctly. this must agree with what you set in the tf files below.
```

### Prepare Terraform

* Initialize Terraform by executing `terraform init`
* Set required variables in `terraform.tfvars`
  * `availability_zones_count` Should be set to number of subnets(private/public) you want to create within vpc.
  * `vpc_cidr` Should be set cidr for vpc. 
  * `aws_region` Should be set to your AWS region
  * `subnet_cidr_bits` Should be set cidr bits for vpc.

* Execute Terraform apply by exeuting `terraform apply`

### Add TAP configuration mandatory details 

Add following details into `/tap-scripts/var.conf` file to fullfill tap prerequisite. Examples and default values given in below sample. All fields are mandatory and can't be leave blank and must be filled before executing the `tap-index.sh` . Please refer below sample config file. 
```
TAP_DEV_NAMESPACE="default"
os=<terminal os as m or l.  m for Mac , l for linux/ubuntu>
INSTALL_BUNDLE=registry.tanzu.vmware.com/tanzu-cluster-essentials/cluster-essentials-bundle@sha256:2f538b69c866023b7d408cce6f0624c5662ee0703d8492e623b7fce10b6f840b
               
INSTALL_REGISTRY_HOSTNAME=registry.tanzu.vmware.com
TAP_VERSION=1.6.3
K8_Version=1.26

tanzu_ess_filename_m=tanzu-cluster-essentials-darwin-amd64-1.6.1.tgz
tanzu_ess_filename_l=tanzu-cluster-essentials-linux-amd64-1.6.1.tgz
tanzu_ess_url_m=https://network.tanzu.vmware.com/api/v2/products/tanzu-cluster-essentials/releases/1358494/product_files/1581689/download
tanzu_ess_url_l=https://network.tanzu.vmware.com/api/v2/products/tanzu-cluster-essentials/releases/1358494/product_files/1581691/download

DOCKERHUB_REGISTRY_URL=index.docker.io
TAP_NAMESPACE="tap-install"
tanzu_net_reg_user=<Provide tanzu net user>
tanzu_net_reg_password=<Provide tanzu net password>
tanzu_net_api_token=<Provide tanzu net token>
registry_url=<Provide user registry url>
registry_user=<Provide user registry userid>
registry_password=<Provide user registry password>
aws_region=<aws region where tap eks clusters created>
tap_full_domain=<full cluster sub domain example like : full.ab-tap.customer0.io >
tap_git_catalog_url=<git catelog url example like : https://github.com/sendjainabhi/tap/blob/main/catalog-info.yaml>
TAP_FULL_CLUSTER_NAME="tap-full"
GITHUB_AUTH_CLIENT_ID=<client ID belonging to the GitHub App to set up the GitHub authorization provider>
GITHUB_AUTH_CLIENT_SECRET=<client Secret belonging to the GitHub App to set up the GitHub authorization provider>
tap_gui_docs_bucket=<S3 bucket hosting the docs>

#tap demo app properties
TAP_APP_NAME="spring-music"
TAP_APP_GIT_URL="https://github.com/PeterEltgroth/spring-music"

```

## Install TAP
### Build EKS clusters 
Execute following steps to build aws resources for TAP. 

*  Execute `terraform plan ` from /terraform directory and review all aws resources.

* Execute `terraform apply` to build aws resources.

### Install TAP single cluster (Full)

Execute following steps to Install TAP single cluster (Full)
```

#Step 1 - Execute Permission to tap-index.sh file
chmod +x /tap-scripts/tap-index.sh

#Step 2 - Execute tap-index file 
./tap-scripts/tap-index.sh


```
**Note** - 

 Pick an external ip from service output from eks full cluster and configure DNS wildcard record in your DNS server for the full cluster
 * **Example full cluster** - *.full.customer0.io ==> <ingress external ip/cname>

### TAP scripts for specific tasks

If you got stuck in any specific stage and need to resume installation , you can use following scripts.Please login to respective EKS cluster before executing these scripts.

* **Install tanzu cli** - execute `./tap-scripts/tanzu-cli-setup.sh`

* **Install tanzu essentials** - execute `./tap-scripts/tanzu-essential-setup.sh`  

* **Setup TAP repository** - execute `./tap-scripts/tanzu-repo.sh`  

* **Install TAP full profile packages** - execute `./tap-scripts/tanzu-full-profile.sh`  

## Clean up

### Delete TAP instances from all eks clusters 

Please follow below steps 
```

# Delete single tap cluster instance 
1. Login to eks cluster(full) using kubeconfig where you want to delete tap.
2. run chmod +x /tap-scripts/tap-delete/tap-delete-single-cluster.sh
3. run cd ./tap-scripts/tap-delete ./tap-delete-single-cluster.sh

```
### Delete EKS cluster instance from eks cluster 
Run `terraform destroy` to destroy to delete all aws resources created by terraform. In some instances it is possible that `terraform destroy` will not be able to clean up after a failed Tanzu install. Especially in situations where the management cluster only comes partially up for whatever reason. In this circumstance you can recursively delete the VPCs that failed to get destroyed and use the tags "CreatedBy: Arcas" to find anything that was generated by this terraform.

### Troubleshooting 
 * if `terraform destroy` command not able to delete aws vpc resources then you can manually delete aws load balancer created by tap under tap vpc and run `terraform destroy` command again. 

### Known issues 
 
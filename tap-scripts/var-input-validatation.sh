#!/bin/bash

source var.conf


if [ -z "$tanzu_net_reg_user" ] || [ -z "$tanzu_net_reg_password" ] || [ -z "$tanzu_net_api_token" ] || [ -z "$aws_region" ] || [ -z "$os" ] 
then 
    echo 'Error : Any of tanzu_net_reg_user,tanzu_net_reg_password,tanzu_net_api_token,aws_region or os fileds cannot be leave empty into var.conf , please add appropriate value!' 
    exit 0 
fi 

if [ -z "$registry_url" ] || [ -z "$registry_user" ] ||  [ -z "$registry_password" ] 
then 
    echo 'Error : Any of registry_url,registry_user or registry_password fileds cannot be leave empty into var.conf , please add appropriate value!' 
    exit 0 
fi 

if [ -z "$tap_full_domain" ] || [ -z "$tap_git_catalog_url" ] 
then 
    echo 'Error : Any of tap_full_domain,tap_git_catalog_url fileds cannot be leave empty into var.conf , please add appropriate value!' 
    exit 0 
fi 

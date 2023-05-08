# Copyright 2022 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause

output "cluster_name-full" {
  value = aws_eks_cluster.full.name

}

output "cluster_endpoint-full" {
  value = aws_eks_cluster.full.endpoint

}

output "vpc_id" {
  value = aws_vpc.main.id
}
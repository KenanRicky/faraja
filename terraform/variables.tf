# AWS Region where resources will be created
variable "aws_region" {
  description = "The AWS region for provisioning resources"
  type        = string
  default     = "us-east-1"
}

# Cluster name used across VPC and EKS tags
variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "faraja-cluster"
}

# Node group instance count
variable "desired_node_count" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}
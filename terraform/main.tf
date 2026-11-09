# Builds the VPC and EKS cluster only; Argo CD deploys the Faraja workloads.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

data "aws_availability_zones" "available" {}

# Public subnets only: nodes get public IPs, so no NAT gateway is needed (saves cost)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name                    = "faraja-vpc"
  cidr                    = "10.0.0.0/16"
  azs                     = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnets          = ["10.0.1.0/24", "10.0.2.0/24"]
  map_public_ip_on_launch = true

  # Lets AWS place the public load balancer for frontend-service here
  public_subnet_tags = { "kubernetes.io/role/elb" = 1 }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "faraja"
  cluster_version = "1.34"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.public_subnets

  # kubectl access from your laptop; whoever runs terraform becomes cluster admin
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  # Lets the gp2 PVC get an EBS disk (README section 9.3)
  cluster_addons = {
    aws-ebs-csi-driver = { most_recent = true }
  }

  eks_managed_node_groups = {
    faraja-nodes = {
      instance_types = ["t3.medium"] # t3.micro allows only 4 pods (README problem #9)
      min_size       = 1
      max_size       = 3
      desired_size   = 2

      # The EBS CSI driver uses the node role to create disks
      iam_role_additional_policies = {
        ebs = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }
    }
  }
}

output "configure_kubectl" {
  value = "aws eks update-kubeconfig --region eu-west-1 --name ${module.eks.cluster_name}"
}

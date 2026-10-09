output "region" {
  value = "us-east-1"
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Kubernetes API URL; use kubectl with AWS authentication, not a browser login."
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 CA certificate. The AWS kubeconfig command configures this automatically."
  value       = module.eks.cluster_certificate_authority_data
}

output "configure_kubectl_command" {
  description = "Run locally using the same AWS identity that created the cluster."
  value       = "aws eks update-kubeconfig --region us-east-1 --name ${module.eks.cluster_name} --alias ${module.eks.cluster_name}"
}

output "aws_console_url" {
  value = "https://us-east-1.console.aws.amazon.com/eks/home?region=us-east-1#/clusters/${module.eks.cluster_name}"
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnet_ids" {
  value = module.vpc.public_subnets
}

output "node_group_name" {
  value = split(":", module.eks.eks_managed_node_groups["demo"].node_group_id)[1]
}

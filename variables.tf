variable "cluster_name" {
  description = "Name of the demo EKS cluster."
  type        = string
  default     = "java-demo-eks"
}

variable "kubernetes_version" {
  description = "An EKS Kubernetes version supported in us-east-1."
  type        = string
  default     = "1.35"
}

variable "cloudshell_principal_arn" {
  description = "Existing IAM user or role used in CloudShell to grant Kubernetes cluster administrator access. Empty disables the entry."
  type        = string
  default     = "arn:aws:iam::820242935759:role/GithubAWSconnection"

  validation {
    condition     = var.cloudshell_principal_arn == "" || can(regex("^arn:aws:iam::[0-9]{12}:(user|role)/.+$", var.cloudshell_principal_arn))
    error_message = "Provide an IAM user or role ARN, not a root ARN or an STS assumed-role session ARN."
  }
}

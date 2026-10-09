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

variable "local_public_ip_cidr" {
  description = "Your computer/network's public IPv4 address followed by /32, allowed to reach the EKS API."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.local_public_ip_cidr)) && can(regex("/32$", var.local_public_ip_cidr))
    error_message = "Enter a valid public IPv4 CIDR for one address, such as 203.0.113.10/32."
  }
}

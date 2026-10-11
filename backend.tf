terraform {
  backend "s3" {
    key          = "java-demo-eks/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
    # Supply the existing bucket name with terraform init -backend-config.
  }
}

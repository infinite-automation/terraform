# Local Terraform setup for AWS EKS

Creates `java-demo-eks` in **us-east-1**, with a VPC, two public subnets, required IAM roles, and one `t3.medium` managed worker node. This is a small learning setup with no NAT gateway. Nodes receive public IPs for outbound downloads; security groups control inbound access. The Kubernetes API allows your configured public IP and internal cluster traffic.

AWS charges apply for the EKS cluster, worker instance, storage, public IPv4 addresses, and logs. Destroy the demo when finished. This creates infrastructure only; it does not deploy the Java application or create a website URL.

## 1. Prepare your computer

Install Terraform 1.5.7+, AWS CLI v2, and kubectl compatible with Kubernetes 1.35 (within one minor version). Configure AWS credentials using your normal AWS profile or SSO login. The identity needs permissions to create EKS, EC2/VPC, IAM roles, KMS, and CloudWatch resources.

```text
aws sts get-caller-identity
cd terraform
```

Use that same AWS profile/role when creating the cluster and running kubectl. The cluster creator receives Kubernetes administrator access. Do not put AWS access keys in Terraform files.

## 2. Set your public IP

Copy the example configuration:

Windows PowerShell:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
(Invoke-RestMethod https://checkip.amazonaws.com).Trim()
```

Linux/macOS:

```sh
cp terraform.tfvars.example terraform.tfvars
curl -4 https://checkip.amazonaws.com
```

Edit `terraform.tfvars`, replacing the example address with the address just printed, followed by `/32`:

```hcl
local_public_ip_cidr = "YOUR_PUBLIC_IPV4/32"
cluster_name         = "java-demo-eks"
kubernetes_version   = "1.35"
```

Use your public internet address, not a local address such as `192.168.x.x`. If your VPN/network changes that address later, update this value and apply again.

## 3. Create the cluster

Run from this `terraform` directory on any platform:

```text
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

Review the plan and enter `yes` when you are ready to create the resources. Creation typically takes several minutes. Terraform stores state locally here: keep it safe, do not commit it, and use the same directory/state for later updates and deletion. Commit `.terraform.lock.hcl` to keep provider versions consistent.

## 4. Connect from your computer

After apply, display the connection command:

```text
terraform output -raw configure_kubectl_command
```

Copy and run that command. With the default name, it is:

```text
aws eks update-kubeconfig --region us-east-1 --name java-demo-eks --alias java-demo-eks
kubectl config current-context
kubectl get nodes
kubectl get pods -A
```

The AWS command merges the cluster connection into your local `~/.kube/config` (on Windows, `%USERPROFILE%\.kube\config`) and selects it as the current context. It configures the endpoint, certificate, and AWS token authentication automatically. Your AWS credentials must remain valid when you use kubectl.

## Outputs

Run `terraform output` to see all outputs:

| Output | Purpose |
| --- | --- |
| `cluster_name`, `region` | Cluster identity and AWS region |
| `cluster_endpoint` | Kubernetes API URL, not the Java website |
| `configure_kubectl_command` | Command to configure your local connection |
| `aws_console_url` | Link to the cluster in the AWS console |
| `cluster_certificate_authority_data` | Cluster CA certificate, automatically used by AWS CLI |
| `vpc_id`, `subnet_ids`, `node_group_name` | Infrastructure identifiers |

For a timeout, check your public IP and network connectivity. For an authentication error, run `aws sts get-caller-identity` and confirm you are using the creator identity and an active SSO session if applicable.

## Delete the demo

Remove any Kubernetes Services/Ingresses that created AWS load balancers, and any application-managed AWS resources first. Then, from this directory:

```text
terraform destroy
```

Review and confirm the deletion. Keep the state files until deletion completes.

Reference: [AWS instructions for configuring local kubectl](https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html).

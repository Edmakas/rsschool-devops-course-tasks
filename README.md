# RS School DevOps Module 1: Basic AWS Infrastructure with Terraform

This repository implements the requirements of [RS School DevOps Module 1, Task 2](https://github.com/rolling-scopes-school/tasks/blob/master/devops/modules/1_basic-configuration/task_2.md). It demonstrates how to set up basic AWS infrastructure using Terraform, manage state in S3, and automate deployments with GitHub Actions.

---

## Prerequisites
- AWS Account
- GitHub Account
- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Terraform 1.12+](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- Git

---

## Setup Instructions

### 1. AWS IAM & S3 State Backend
- Create an **IAM user** with these policies:
  - AmazonEC2FullAccess
  - AmazonRoute53FullAccess
  - AmazonS3FullAccess
  - IAMFullAccess
  - AmazonVPCFullAccess
  - AmazonSQSFullAccess
  - AmazonEventBridgeFullAccess
- Enable MFA for both root and IAM user.
- Create an **S3 bucket** for Terraform state:
  ```bash
  aws s3api create-bucket --bucket <your-terraform-state-bucket> --region <your-region>
  ```
- Configure your `backend` in Terraform to use this S3 bucket.

### 2. AWS CLI Configuration
```bash
aws configure
# Enter Access Key, Secret Key, region, and output format
```
Test with:
```bash
aws ec2 describe-instance-types --instance-types t4g.nano
```

### 3. GitHub Actions IAM Role (for CI/CD)
- The Terraform code for creating the `GithubActionsRole` IAM role is located in the `Setup` directory of this repository (`Setup/iam.tf`).
- This role should have the same permissions as the IAM user described above.
- Set up an OIDC identity provider for GitHub Actions in your AWS account.
- Configure the trust policy to allow GitHub Actions to assume this role securely.

### 4. GitHub Repository Secrets/Variables
- `AWS_ACCOUNT_ID` (secret): Your AWS account ID
- `SSH_PUBLIC_KEY` (secret): Public key for bastion host
- `GithubActionsRole` (variable): Name of the IAM role for GitHub Actions
- `vpc_cidr` (variable): CIDR block for VPC
- `IPS_TO_BASTION` (variable): List of CIDR blocks allowed to SSH to the bastion host

---

## Project Structure
```
.
├── Infrastructure/
│   ├── .terraform.lock.hcl
│   ├── backends.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   ├── variables.tf
│   ├── providers.tf
│   ├── modules/
│   │   └── infra/
│   │       ├── bastion.tf
│   │       ├── ec2.tf
│   │       ├── k3s_nodes.tf
│   │       ├── nacl.tf
│   │       ├── nat.tf
│   │       ├── outputs.tf
│   │       ├── security_groups.tf
│   │       ├── security_groups_k3s.tf
│   │       ├── test_ec2.tf
│   │       ├── vpc.tf
│   │       ├── variables.tf
│   │       └── _nacl copy.tf_
│   └── .terraform/
├── Setup/
│   ├── .terraform.lock.hcl
│   ├── iam.tf
│   ├── main.tf
│   ├── terraform.tfvars
│   ├── variables.tf
│   └── .terraform/
├── .github/
│   └── workflows/
│       ├── terraform-create.yml
│       └── terraform-destroy.yml
├── .gitignore
└── README.md
```

### Directory and File Descriptions
- **Infrastructure/**: Main Terraform configuration for AWS infrastructure (VPC, subnets, NAT, bastion, K3s nodes, etc.)
  - **main.tf**: Root Terraform module, includes the infra module
  - **variables.tf**: Variable definitions for the infrastructure
  - **outputs.tf**: Outputs from the infrastructure
  - **backends.tf**: S3 backend configuration for state
  - **terraform.tfvars**: Variable values (not committed if sensitive)
  - **providers.tf**: Provider configuration
  - **modules/infra/**: Reusable module for core AWS resources
    - **bastion.tf**: Bastion host EC2 instance and SSH key pair (with user_data for hostname and kubectl install; provisioners are commented out)
    - **ec2.tf**: Additional EC2 resources if any
    - **k3s_nodes.tf**: EC2 instances for K3s nodes
    - **security_groups.tf**: Security group definitions (bastion, private, etc.)
    - **security_groups_k3s.tf**: Security group for K3s nodes (all required K3s ports)
    - **nacl.tf**: Network ACLs
    - **nat.tf**: NAT gateway and routing
    - **outputs.tf**: Module outputs
    - **variables.tf**: Module variables
    - **test_ec2.tf**: Test EC2 instances (for learning/testing)
- **Setup/**: Terraform code for initial AWS setup (IAM role for GitHub Actions)
  - **iam.tf**: IAM role and policies for GitHub Actions
  - **main.tf**: Terraform backend and provider config
  - **variables.tf**: Variable definitions for setup
  - **terraform.tfvars**: Variable values for setup (not committed if sensitive)
- **.github/workflows/**: GitHub Actions CI/CD workflows
  - **terraform-create.yml**: Workflow for provisioning/updating infrastructure
  - **terraform-destroy.yml**: Workflow for destroying infrastructure
- **.gitignore**: Standard gitignore for Terraform projects
- **README.md**: This documentation file

---

## GitHub Actions Workflows
- **terraform-create.yml**: Runs on push/PR to main, develop, or task_* branches. Performs `terraform init`, `terraform fmt`, and `terraform apply` in the `Infrastructure` directory using the IAM role and secrets. This workflow ensures your infrastructure is always up to date with your codebase.
- **terraform-destroy.yml**: Manual workflow to destroy all resources. This is useful for cleanup and cost control. It runs `terraform init` and `terraform destroy -auto-approve` in the `Infrastructure` directory.

---

## What This Project Does
- Provisions a VPC with public/private subnets, NAT, and bastion host, two nodes for K3S installation
- Manages state in S3
- Uses modules for infrastructure
- Automates deployment and destroy via GitHub Actions

---

### Deployment Steps
1. **Clone the repository**
2. **Configure your AWS credentials** (e.g., using `aws configure`)
3. **Set required variables** in `terraform.tfvars` or via environment variables (see `variables.tf` for details)
4. **Initialize Terraform**:
   ```bash
   cd Infrastructure
   terraform init
   ```
5. **Review the plan**:
   ```bash
   terraform plan
   ```
6. **Apply the configuration**:
   ```bash
   terraform apply
   ```
7. **Access the bastion host** using the generated SSH key
8. **Install and configure K3s** on your nodes (manually or via automation)

## K3s (Kubernetes) Cluster Setup and Deployment

This project provisions a lightweight Kubernetes (K3s) cluster on AWS using Terraform. The setup includes:
- A VPC with public and private subnets
- A bastion host for secure SSH access
- Security groups for bastion, private nodes, and K3s nodes (with all required K3s ports)
- EC2 instances for K3s nodes (can be used as server or agent nodes)
- All networking and IAM resources required for a secure, functional cluster

### K3s Security Group
The file `modules/infra/security_groups_k3s.tf` defines all required inbound rules for K3s nodes, as per the [official K3s requirements](https://docs.k3s.io/installation/requirements). All ports are restricted to the VPC CIDR for security.

### How to Install K3s on Two Nodes

After provisioning your infrastructure with Terraform, you can install K3s on your two EC2 nodes (one as server, one as agent) as follows:

### 1. SSH into the K3s Server Node
- Use the bastion host as a jump box

### 2. Install K3s Server
- On the server node, run:
  ```bash
  curl -sfL https://get.k3s.io | sh -
  # Check status
  sudo k3s kubectl get node
  # Get the node token for agent join
  sudo cat /var/lib/rancher/k3s/server/node-token
  ```

### 3. SSH into the K3s Agent Node
- Again, use the bastion as a jump box:
  ```bash
  ssh -i /path/to/your/private_key -J ubuntu@<bastion_public_ip> ubuntu@<k3s_agent_private_ip>
  ```

### 4. Install K3s Agent
- On the agent node, replace `<server_private_ip>` and `<token>` with your actual values:
  ```bash
  curl -sfL https://get.k3s.io | K3S_URL="https://<server_private_ip>:6443" K3S_TOKEN="<token>" sh -
  ```

### 5. Verify the Cluster
- On the server node:
  ```bash
  sudo k3s kubectl get nodes
  ```
  You should see both the server and agent nodes listed as Ready.

**Tip:** You can copy the kubeconfig from the server node (`/etc/rancher/k3s/k3s.yaml`) to your local machine for direct `kubectl` access.

For more details, see the [official K3s installation guide](https://docs.k3s.io/installation/quick-start).

---

## References
- [RS School Task 2 Description](https://github.com/rolling-scopes-school/tasks/blob/master/devops/modules/1_basic-configuration/task_2.md)
- [AWS CLI Docs](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Terraform Docs](https://developer.hashicorp.com/terraform/docs)

---

## Author
Edmundas

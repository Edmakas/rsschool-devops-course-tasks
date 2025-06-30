# RS School DevOps Module 1: Automated AWS Infrastructure with K3s Cluster

This repository implements the requirements of [RS School DevOps Module 1, Task 2](https://github.com/rolling-scopes-school/tasks/blob/master/devops/modules/1_basic-configuration/task_2.md). It demonstrates how to set up a complete AWS infrastructure with an **automated K3s Kubernetes cluster** using Terraform, manage state in S3, and automate deployments with GitHub Actions.

## 🚀 **NEW: Fully Automated K3s Installation**

**No manual work required!** This project now automatically:
- ✅ **Installs K3s server** on node-1 (master)
- ✅ **Installs K3s agent** on node-2 (worker) 
- ✅ **Configures kubectl** on bastion host
- ✅ **Deploys test pod** to verify cluster functionality
- ✅ **Sets up SSH keys** for secure node communication
- ✅ **Configures all networking** and security groups

The entire K3s cluster is ready to use immediately after Terraform deployment!

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
- `SSH_PRIVATE_KEY` (secret): Private key for node communication
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
│   │       ├── bastion_userdata.sh.tpl
│   │       ├── node1_userdata.sh.tpl
│   │       ├── node2_userdata.sh.tpl
│   │       ├── k3s_nodes.tf
│   │       ├── nat_gateway.tf
│   │       ├── outputs.tf
│   │       ├── security_groups.tf
│   │       ├── security_groups_k3s.tf
│   │       ├── vpc.tf
│   │       └── variables.tf
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
│       └── terraform-plan-create.yml
├── .gitignore
└── README.md
```

### Directory and File Descriptions

#### **Infrastructure/** - Main Terraform configuration for AWS infrastructure
- **main.tf**: Root Terraform module with conditional SSH key handling (local file vs GitHub secrets)
- **variables.tf**: Variable definitions for the infrastructure
- **outputs.tf**: Outputs from the infrastructure (VPC, subnet info, bastion IP, node IPs)
- **backends.tf**: S3 backend configuration for state management
- **terraform.tfvars**: Variable values (public key, VPC CIDR, etc.)
- **providers.tf**: AWS provider configuration

#### **Infrastructure/modules/infra/** - Core AWS resources module
- **bastion.tf**: Bastion host EC2 instance with automated kubectl setup and test pod deployment
- **bastion_userdata.sh.tpl**: Template for bastion host initialization (kubectl install, SSH key setup, cluster access)
- **node1_userdata.sh.tpl**: Template for K3s master node (node-1) setup with server installation
- **node2_userdata.sh.tpl**: Template for K3s worker node (node-2) setup with agent installation and cluster joining
- **k3s_nodes.tf**: EC2 instances for K3s nodes with proper dependencies and user data templates
- **security_groups.tf**: Security group definitions (bastion, private instances with SSH/ICMP between nodes)
- **security_groups_k3s.tf**: Security group for K3s nodes (all required K3s ports: 6443, 8472, 10250, etc.)
- **vpc.tf**: VPC, subnets, internet gateway, and route tables
- **nat_gateway.tf**: NAT gateway for private subnet internet access
- **outputs.tf**: Module outputs (VPC info, subnet CIDRs, bastion IP, node IPs)
- **variables.tf**: Module variables

#### **Setup/** - Initial AWS setup (IAM role for GitHub Actions)
- **iam.tf**: IAM role and policies for GitHub Actions with OIDC trust
- **main.tf**: Terraform backend and provider configuration
- **variables.tf**: Variable definitions for setup
- **terraform.tfvars**: Variable values for setup

#### **.github/workflows/** - GitHub Actions CI/CD workflows
- **terraform-plan-create.yml**: Automated workflow for infrastructure provisioning with GitHub secrets integration

---

## 🎯 **Automated K3s Cluster Features**

### **What Gets Deployed Automatically:**

1. **Infrastructure Layer:**
   - VPC with public/private subnets across 2 AZs
   - NAT Gateway for private subnet internet access
   - Bastion host in public subnet for secure access
   - Security groups with all required K3s ports

2. **K3s Cluster Layer:**
   - **node-1**: K3s server (master) with automatic installation
   - **node-2**: K3s agent (worker) with automatic cluster joining
   - **Bastion**: kubectl configured with cluster access
   - **Test deployment**: Simple nginx pod deployed automatically

3. **Security Layer:**
   - SSH keys automatically distributed to all nodes
   - Security groups allowing SSH/ICMP between nodes
   - K3s-specific ports (6443, 8472, 10250, etc.) configured
   - Private subnets for worker nodes

### **Cluster Verification:**
After deployment, the bastion host automatically:
- Deploys a test nginx pod
- Verifies cluster connectivity
- Shows node and pod status

---

## GitHub Actions Workflow

### **terraform-plan-create.yml**
- **Triggers**: Push/PR to main, develop, or task_* branches
- **Features**:
  - Uses GitHub secrets for SSH keys (`SSH_PRIVATE_KEY`, `SSH_PUBLIC_KEY`)
  - AWS OIDC authentication via IAM role
  - Two-stage deployment (plan → apply)
  - Automatic infrastructure updates

---

## Deployment Steps

### **Option 1: GitHub Actions (Recommended)**
1. **Set GitHub secrets** (SSH keys, AWS account ID)
2. **Set GitHub variables** (VPC CIDR, bastion IPs, IAM role name)
3. **Push to main branch** - infrastructure deploys automatically
4. **Access bastion host** - K3s cluster is ready to use

### **Option 2: Local Deployment**
1. **Clone the repository**
2. **Configure AWS credentials**
3. **Initialize and apply**:
   ```bash
   cd Infrastructure
   terraform init
   terraform plan
   terraform apply
   ```
4. **Access bastion host** - K3s cluster is ready to use

---

## 🚀 **Post-Deployment Access**

### **Connect to Bastion Host:**
```bash
ssh -i ~/.ssh/bastion_aws_test_rsa ubuntu@<bastion-public-ip>
```

### **Verify K3s Cluster:**
```bash
# Check nodes
kubectl get nodes

# Check pods
kubectl get pods

# Check services
kubectl get services
```

### **Access Worker Nodes (via bastion):**
```bash
ssh ubuntu@<node1-private-ip>  # K3s master
ssh ubuntu@<node2-private-ip>  # K3s worker
```

---

## 🔧 **Infrastructure Details**

### **Network Architecture:**
- **VPC**: 10.0.0.0/16
- **Public Subnet**: 10.0.0.0/24 (bastion host)
- **Private Subnet 1**: 10.0.10.0/24 (node-1, K3s master)
- **Private Subnet 2**: 10.0.11.0/24 (node-2, K3s worker)

### **Instance Types:**
- **Bastion**: t2.micro (Ubuntu 22.04)
- **K3s Nodes**: t2.medium (Ubuntu 22.04)

### **Security Groups:**
- **Bastion**: SSH from allowed IPs only
- **Private**: SSH from bastion + SSH/ICMP between nodes
- **K3s**: All required K3s ports (6443, 8472, 10250, etc.)

---

## 📊 **Terraform Code Statistics**
- **Total Lines**: 691 lines of Terraform code
- **Infrastructure Module**: 448 lines (65% of total)
- **Core Infrastructure**: 562 lines (81% of total)
- **Setup/IAM**: 129 lines (19% of total)

---

## 🎉 **What You Get**

After running this Terraform configuration, you'll have:
- ✅ **Complete K3s cluster** ready for application deployment
- ✅ **Secure networking** with proper security groups
- ✅ **Automated setup** - no manual configuration required
- ✅ **CI/CD ready** with GitHub Actions integration
- ✅ **Production-ready** infrastructure as code
- ✅ **Cost-optimized** setup with NAT gateway in single AZ

**No manual K3s installation or configuration needed!** 🚀

---

## References
- [RS School Task 2 Description](https://github.com/rolling-scopes-school/tasks/blob/master/devops/modules/1_basic-configuration/task_2.md)
- [AWS CLI Docs](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Terraform Docs](https://developer.hashicorp.com/terraform/docs)

---

## Author
Edmundas

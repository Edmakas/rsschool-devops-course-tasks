# RS School: AWS DevOps 2025Q2

This project automates AWS infrastructure provisioning and K3s Kubernetes cluster deployment using Terraform and GitHub Actions. Jenkins is deployed on the cluster with all required Kubernetes prerequisites handled automatically.

---

## Detailed Directory Structure & File Descriptions

```
.
├── Infrastructure/                        # Terraform code for AWS infrastructure
│   ├── main.tf                            # Root Terraform config, includes modules
│   ├── variables.tf                       # Variable definitions for infrastructure
│   ├── outputs.tf                         # Outputs for VPC, subnets, IPs, etc.
│   ├── backends.tf                        # S3 backend config for state management
│   ├── providers.tf                       # AWS provider configuration
│   ├── .terraform.lock.hcl                # Terraform provider lock file
│   ├── .terraform/                        # Terraform state and cache (auto-generated)
│   └── modules/
│       └── infra/                         # Core AWS resources module
│           ├── bastion.tf                 # Bastion host EC2 instance
│           ├── bastion_userdata.sh.tpl    # Bastion host initialization script
│           ├── node1_userdata.sh.tpl      # K3s master node (server) setup script
│           ├── node2_userdata.sh.tpl      # K3s worker node (agent) setup script
│           ├── k3s_nodes.tf               # EC2 instances for K3s nodes
│           ├── nat_gateway.tf             # NAT gateway for private subnet
│           ├── outputs.tf                 # Module outputs (VPC info, IPs, etc.)
│           ├── security_groups.tf         # Security groups for bastion and nodes
│           ├── security_groups_k3s.tf     # Security groups for K3s-specific ports
│           ├── security_groups_jenkins.tf # Security group for Jenkins
│           ├── ssh_keys.tf                # SSH key resources
│           ├── vpc.tf                     # VPC, subnets, IGW, route tables
│           └── variables.tf               # Module variable definitions
├── Setup/                                 # Terraform for initial AWS setup (IAM)
│   ├── iam.tf                             # IAM role and policies for GitHub Actions
│   ├── main.tf                            # Terraform backend and provider config
│   ├── variables.tf                       # Variable definitions for setup
│   ├── .terraform.lock.hcl                # Terraform provider lock file
│   └── .terraform/                        # Terraform state and cache (auto-generated)
├── K3S_Manifests/                         # Kubernetes manifests & Helm values
│   ├── README.md                          # K3S manifests usage and workflow info
│   └── Mod3_Task4/
│       ├── jenkins-values.yaml            # Jenkins Helm chart values (custom config)
│       ├── commands.txt                   # Useful Helm/K8s commands
│       └── Prerequisites/                 # Jenkins prerequisites for K8s
│           ├── prerequisites-jenkins-NS.yaml      # Namespace for Jenkins
│           ├── prerequisites-jenkins-SC.yaml      # StorageClass for Jenkins PV
│           ├── prerequisites-jenkins-SA.yaml      # ServiceAccount, ClusterRole, ClusterRoleBinding for Jenkins
│           ├── prerequisites-jenkins-Ingress.yaml # (Optional) Ingress for Jenkins
│           └── prerequisites-command.txt          # Helm install commands
├── .github/
│   └── workflows/
│       ├── k3s-deploy.yml                 # Main CI/CD: infra, prerequisites, Jenkins
│       ├── k3s-manage.yml                 # Cluster management actions (status, logs, etc.)
│       ├── terraform-plan-create.yml      # Infra provisioning (plan/apply)
│       └── terraform-destroy.yml          # Infra teardown
├── .gitignore                             # Git ignore rules
└── README.md                              # Project documentation (this file)
```

### File & Directory Descriptions
- **Infrastructure/**: All Terraform code for AWS (VPC, EC2, security, etc.)
  - **modules/infra/**: Core AWS resources, user data scripts, security, and outputs
- **Setup/**: Terraform for IAM roles and initial AWS setup
- **K3S_Manifests/Mod3_Task4/jenkins-values.yaml**: Jenkins Helm chart configuration (NodePort, plugins, etc.)
- **K3S_Manifests/Mod3_Task4/Prerequisites/**: Kubernetes YAMLs for Jenkins namespace, storage, RBAC, and ingress
  - **prerequisites-jenkins-NS.yaml**: Creates the `jenkins` namespace
  - **prerequisites-jenkins-SC.yaml**: Defines a StorageClass for Jenkins persistent volumes
  - **prerequisites-jenkins-SA.yaml**: ServiceAccount, ClusterRole, and ClusterRoleBinding for Jenkins
  - **prerequisites-jenkins-Ingress.yaml**: (Optional) Ingress resource for Jenkins
  - **prerequisites-command.txt**: (Optional) Helm install and repo commands
- **.github/workflows/**: GitHub Actions workflows
  - **k3s-deploy.yml**: Provisions infra, applies Jenkins prerequisites, installs Jenkins via Helm
  - **k3s-manage.yml**: Cluster management (get status, logs, restart Jenkins, etc.)
  - **terraform-plan-create.yml**: Infrastructure provisioning (plan/apply)
  - **terraform-destroy.yml**: Infrastructure teardown

---

## Quick Usage
1. Configure your AWS and GitHub secrets/variables as described in the workflow comments.
2. Push changes to the repository—**GitHub Actions will handle everything** (infra, K3s, Jenkins, prerequisites).
3. Access Jenkins at `http://<master-node-ip>:30111` (admin password is shown in workflow logs).

---

## Prerequisites
- AWS Account
- GitHub Account
- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Terraform 1.12+](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- Git

---

## Setup Instructions

### 1. GitHub Actions IAM Role (for CI/CD)
- The Terraform code for creating the `GithubActionsRole` IAM role is located in the `Setup` directory of this repository (`Setup/iam.tf`).
- This role should have the same permissions as the IAM user described above.
- Set up an OIDC identity provider for GitHub Actions in your AWS account.
- Configure the trust policy to allow GitHub Actions to assume this role securely.

### 4. GitHub Repository Secrets and Variables

For GitHub Actions CI/CD to work, you must set the following in your repository:

### **Secrets**
- `AWS_ACCOUNT_ID`: Your AWS account ID (12 digits)
- `SSH_PUBLIC_KEY`: Public key for bastion host and nodes
- `SSH_PRIVATE_KEY`: Private key for node communication

### **Variables**
- `GithubActionsRole`: Name of the IAM role for GitHub Actions (e.g., `GithubActionsRole`)
- `vpc_cidr`: CIDR block for your VPC (e.g., `10.0.0.0/16`)
- `NODE_INSTANCE_PROFILE` (variable): Instance profile 

---

## 🎯 **Automated K3s Cluster Features**

### **What Gets Deployed Automatically:**

1. **Infrastructure Layer:**
   - VPC with public subnet   
   - Security groups with all required K3s/Jenkins ports

2. **K3s Cluster Layer:**
   - **node-1**: K3s server (master) with automatic installation
   - **node-2**: K3s agent (worker) with automatic cluster joining

3. **Security Layer:**
   - SSH keys automatically distributed to all nodes
   - Security groups allowing SSH/ICMP between nodes
   - K3s-specific ports (6443, 8472, 10250, etc.) configured
   - Private subnets for worker nodes

---

## GitHub Actions Workflows

### terraform-plan-create.yml
- **Purpose:** Provisions AWS infrastructure using Terraform.
- **Triggers:** On push/PR to main, develop, or task_* branches.
- **Features:**
  - Runs `terraform plan` and `terraform apply` using secrets and OIDC authentication.
  - Handles infrastructure updates automatically.

### k3s-deploy.yml
- **Purpose:** Deploys to the K3s cluster after infrastructure is ready.
- **Features:**
  - Waits for K3s to be ready.
  - Applies all Jenkins Kubernetes prerequisites (namespace, StorageClass, RBAC, etc.).
  - Installs Jenkins via Helm with custom values.
  - Outputs Jenkins access info and admin password.
  - Applies any additional manifests in the K3S_Manifests directory.

### k3s-manage.yml
- **Purpose:** Provides cluster management and troubleshooting actions.
- **Features:**
  - Allows you to check cluster status, get logs, restart Jenkins, and apply manifests.
  - Can be triggered manually from the GitHub Actions UI.

### terraform-destroy.yml
- **Purpose:** Tears down all provisioned AWS infrastructure.
- **Features:**
  - Runs `terraform destroy` safely using the same secrets and OIDC authentication.
  - Can be triggered manually to clean up all resources.

---

## Deployment Steps

### **Option 1: GitHub Actions**
1. **Set GitHub secrets**
2. **Set GitHub variables**
3. **Push to main branch**

### **Option 2: Local Deployment**
1. **Clone the repository**
2. **Configure AWS credentials**
4. **Set variables locally**
5. **Initialize and apply**:
   ```bash
   cd Infrastructure
   terraform init
   terraform plan
   terraform apply
   ```
6. **Access K3S worker host**

---

## References
- [RS School Task 2 Description](https://github.com/rolling-scopes-school/tasks/blob/master/devops/modules/1_basic-configuration/task_2.md)
- [AWS CLI Docs](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Terraform Docs](https://developer.hashicorp.com/terraform/docs)

---

## Author
Edmundas

---

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
│       ├── infra/                         # Core AWS resources module
│       │   ├── bastion.tf                 # Bastion host EC2 instance
│       │   ├── bastion_userdata.sh.tpl    # Bastion host initialization script
│       │   ├── node1_userdata.sh.tpl      # K3s master node (server) setup script
│       │   ├── node2_userdata.sh.tpl      # K3s worker node (agent) setup script
│       │   ├── k3s_nodes.tf               # EC2 instances for K3s nodes
│       │   ├── nat_gateway.tf             # NAT gateway for private subnet
│       │   ├── outputs.tf                 # Module outputs (VPC info, IPs, etc.)
│       │   ├── security_groups.tf         # Security groups for bastion and nodes
│       │   ├── security_groups_k3s.tf     # Security groups for K3s-specific ports
│       │   ├── security_groups_jenkins.tf # Security group for Jenkins
│       │   ├── ssh_keys.tf                # SSH key resources
│       │   ├── vpc.tf                     # VPC, subnets, IGW, route tables
│       │   └── variables.tf               # Module variable definitions
│       └── route53/                       # Route53 DNS management module
│           ├── main.tf                    # Route53 zone and record resources
│           ├── variables.tf               # Route53 module variables
│           ├── outputs.tf                 # Route53 module outputs
│           └── README.md                  # Route53 module documentation
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
│       ├── k3s-deploy.yml                 # Main CI/CD: infra, prerequisites, Jenkins, DNS
│       ├── k3s-manage.yml                 # Cluster management actions (status, logs, etc.)
│       ├── terraform-plan-create.yml      # Infra provisioning (plan/apply)
│       ├── terraform-destroy.yml          # Infra teardown
│       └── route53-update.yml             # Manual Route53 DNS record updates
├── .gitignore                             # Git ignore rules
└── README.md                              # Project documentation (this file)
```

### File & Directory Descriptions
- **Infrastructure/**: All Terraform code for AWS (VPC, EC2, security, Route53, etc.)
  - **modules/infra/**: Core AWS resources, user data scripts, security, and outputs
  - **modules/route53/**: Route53 DNS management for Jenkins domain records
- **Setup/**: Terraform for IAM roles and initial AWS setup
- **K3S_Manifests/Mod3_Task4/jenkins-values.yaml**: Jenkins Helm chart configuration (NodePort, plugins, etc.)
- **K3S_Manifests/Mod3_Task4/Prerequisites/**: Kubernetes YAMLs for Jenkins namespace, storage, RBAC, and ingress
  - **prerequisites-jenkins-NS.yaml**: Creates the `jenkins` namespace
  - **prerequisites-jenkins-SC.yaml**: Defines a StorageClass for Jenkins persistent volumes
  - **prerequisites-jenkins-SA.yaml**: ServiceAccount, ClusterRole, and ClusterRoleBinding for Jenkins
  - **prerequisites-jenkins-Ingress.yaml**: Ingress resource for Jenkins with dynamic domain configuration
  - **prerequisites-command.txt**: (Optional) Helm install and repo commands
- **.github/workflows/**: GitHub Actions workflows
  - **k3s-deploy.yml**: Provisions infra, applies Jenkins prerequisites, installs Jenkins via Helm, manages DNS
  - **k3s-manage.yml**: Cluster management (get status, logs, restart Jenkins, etc.)
  - **terraform-plan-create.yml**: Infrastructure provisioning (plan/apply)
  - **terraform-destroy.yml**: Infrastructure teardown
  - **route53-update.yml**: Manual Route53 DNS record updates

---

## Quick Usage
1. Configure your AWS and GitHub secrets/variables as described in the workflow comments.
2. Set up your Route53 hosted zone and GitHub Actions `domain_name` variable.
3. Push changes to the repository—**GitHub Actions will handle everything** (infra, K3s, Jenkins, prerequisites, DNS).
4. Access Jenkins at `http://jenkins.<your-domain>` or `http://<master-node-ip>:30111` (admin password is shown in workflow logs).

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
- `node_instance_profile`: Instance profile for K3s nodes
- `domain_name`: Your domain name for Route53 DNS management (e.g., `tuselis.lt`)
- `IPS_TO_BASTION`: IP addresses allowed to access bastion host 

---

### **What Gets Deployed Automatically:**

1. **Infrastructure Layer:**
   - VPC with public subnet   
   - Security groups with all required K3s/Jenkins ports

2. **K3s Cluster Layer:**
   - **node-1**: K3s server (master) with automatic installation
   - **node-2**: K3s agent (worker) with automatic cluster joining

3. **DNS Management Layer:**
   - Route53 A record for `jenkins.<your-domain>` pointing to K3s master node
   - Automatic DNS updates during infrastructure deployment
   - Support for manual DNS updates via GitHub Actions workflow

4. **Security Layer:**
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
  - Creates/updates Route53 DNS records for Jenkins domain.
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

### route53-update.yml
- **Purpose:** Manually update Route53 DNS records for Jenkins.
- **Features:**
  - Allows manual DNS record updates with a new IP address.
  - Can be triggered manually from GitHub Actions UI.
  - Useful when IP addresses change outside of normal deployment.

---

## Deployment Steps

### **Option 1: GitHub Actions (Recommended)**
1. **Set GitHub secrets** (AWS credentials, SSH keys)
2. **Set GitHub variables** (domain_name, vpc_cidr, etc.)
3. **Ensure Route53 hosted zone exists** for your domain
4. **Push to main branch** - GitHub Actions handles everything automatically

### **Option 2: Local Deployment**
1. **Clone the repository**
2. **Configure AWS credentials**
3. **Set variables locally** (including domain_name)
4. **Initialize and apply**:
   ```bash
   cd Infrastructure
   terraform init
   terraform plan
   terraform apply
   ```
5. **Access Jenkins** at `http://jenkins.<your-domain>` or `http://<master-node-ip>:30111`

---

## DNS Management and Domain Configuration

### **Route53 Integration**
This project includes automatic DNS management using AWS Route53:

- **Automatic DNS Creation**: Creates `jenkins.<your-domain>` A record pointing to the K3s master node
- **Dynamic Domain Support**: Uses GitHub Actions variable `domain_name` for flexible domain configuration
- **Automatic Updates**: DNS records are updated automatically during infrastructure deployment
- **Manual Updates**: Use the `route53-update.yml` workflow for manual DNS record updates

### **Domain Setup Requirements**
1. **Route53 Hosted Zone**: Must exist for your domain (e.g., `tuselis.lt`)
2. **GitHub Actions Variable**: Set `domain_name` variable (e.g., `tuselis.lt`)
3. **AWS Permissions**: GitHub Actions role needs Route53 permissions

### **Access URLs**
After deployment, Jenkins is accessible via:
- **Domain**: `http://jenkins.<your-domain>` (e.g., `http://jenkins.tuselis.lt`)
- **Direct IP**: `http://<master-node-ip>:30111`

### **DNS Troubleshooting**
- **Manual DNS Update**: Use the `route53-update.yml` workflow if IP addresses change
- **Check DNS Propagation**: DNS changes may take a few minutes to propagate
- **Verify Hosted Zone**: Ensure your Route53 hosted zone is properly configured

---

## References
- [RS School Task 2 Description](https://github.com/rolling-scopes-school/tasks/blob/master/devops/modules/1_basic-configuration/task_2.md)
- [AWS CLI Docs](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Terraform Docs](https://developer.hashicorp.com/terraform/docs)
- [AWS Route53 Docs](https://docs.aws.amazon.com/route53/)

---

## Author
Edmundas

---

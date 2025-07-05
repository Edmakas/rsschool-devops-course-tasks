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
│   └── modules/
│       ├── infra/                         # Core AWS resources module
│       │   ├── k3s_nodes.tf               # EC2 instances for K3s nodes
│       │   ├── node1_userdata.sh.tpl      # K3s master node (server) setup script
│       │   ├── node2_userdata.sh.tpl      # K3s worker node (agent) setup script ( not used in the current version)
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
│   └── variables.tf                       # Variable definitions for setup
├── K3S_Manifests/                         # Kubernetes manifests & Helm values
│   ├── README.md                          # K3S manifests usage and workflow info
│   └── Mod3_Task4/
│       ├── jenkins-values.yaml            # Jenkins Helm chart values (custom config)
│       └── Prerequisites/                 # Jenkins prerequisites for K8s
│           ├── prerequisites-jenkins-NS.yaml      # Namespace for Jenkins
│           ├── prerequisites-jenkins-SC.yaml      # StorageClass for Jenkins PV
│           ├── prerequisites-jenkins-SA.yaml      # ServiceAccount, ClusterRole, ClusterRoleBinding for Jenkins
│           ├── prerequisites-jenkins-Ingress.yaml # Ingress for Jenkins with dynamic domain
│           └── letsencrypt-staging-clusterissuer.yaml # Let's Encrypt staging cluster issuer
├── .github/
│   └── workflows/
│       ├── k3s-deploy.yml                 # Main CI/CD: infra, prerequisites, Jenkins, DNS
│       ├── k3s-manage.yml                 # Cluster management actions (status, logs, etc.)
│       ├── terraform-plan-create.yml      # Infra provisioning (plan/apply)
│       ├── terraform-destroy.yml          # Infra teardown
│       ├── k3s-destroy-deployments.yml    # K3S workload destruction
│       ├── route53-update.yml             # Manual Route53 DNS record updates
│       └── cert-manager-deploy.yml        # Cert-Manager deployment workflow
└── README.md                              # Project documentation (this file)
```

### File & Directory Descriptions
- **Infrastructure/**: All Terraform code for AWS (VPC, EC2, security, Route53, etc.)
  - **modules/infra/**: Core AWS resources, user data scripts, security groups, and outputs
  - **modules/route53/**: Route53 DNS management for Jenkins domain records
- **Setup/**: Terraform for IAM roles and initial AWS setup
- **K3S_Manifests/Mod3_Task4/jenkins-values.yaml**: Jenkins Helm chart configuration (NodePort, plugins, etc.)
- **K3S_Manifests/Mod3_Task4/Prerequisites/**: Kubernetes YAMLs for Jenkins namespace, storage, RBAC, ingress, and SSL
  - **prerequisites-jenkins-NS.yaml**: Creates the `jenkins` namespace
  - **prerequisites-jenkins-SC.yaml**: Defines a StorageClass for Jenkins persistent volumes
  - **prerequisites-jenkins-SA.yaml**: ServiceAccount, ClusterRole, and ClusterRoleBinding for Jenkins
  - **prerequisites-jenkins-Ingress.yaml**: Ingress resource for Jenkins with dynamic domain configuration
  - **letsencrypt-staging-clusterissuer.yaml**: Let's Encrypt staging cluster issuer for SSL certificates
- **.github/workflows/**: GitHub Actions workflows
  - **k3s-deploy.yml**: Main CI/CD workflow - deploys infra, applies Jenkins prerequisites, installs Jenkins via Helm, manages DNS
  - **k3s-manage.yml**: Cluster management (get status, logs, restart Jenkins, etc.)
  - **terraform-plan-create.yml**: Infrastructure provisioning (plan/apply)
  - **terraform-destroy.yml**: Infrastructure teardown with Route53 cleanup
  - **k3s-destroy-deployments.yml**: K3S workload and Jenkins destruction
  - **route53-update.yml**: Manual Route53 DNS record updates
  - **cert-manager-deploy.yml**: Cert-Manager deployment for SSL certificate management

---

## Quick Usage

### **Creating Infrastructure:**
1. Configure your AWS and GitHub secrets/variables as described in the workflow comments.
2. Set up your Route53 hosted zone and GitHub Actions `domain_name` variable.
3. **Go to GitHub Actions** → **"Create AWS infra, K3S"** workflow → **"Run workflow"**
4. **Sit back and watch** - everything happens automatically:
   - ✅ Creates AWS infrastructure (VPC, EC2 instances, security groups)
   - ✅ Deploys K3S cluster and Jenkins
   - ✅ Updates Route53 DNS records
   - ✅ Provides access information
5. Access Jenkins at `http://jenkins.<your-domain>` or `http://<master-node-ip>:30111` (admin password is shown in workflow logs).

### **Destroying Infrastructure:**
1. **Go to GitHub Actions** → **"Destroy K3S Workload"** workflow → **"Run workflow"**
2. **Sit back and watch** - everything gets cleaned up automatically:
   - ✅ Uninstalls Jenkins and deletes namespace
   - ✅ Cleans up Route53 DNS records
   - ✅ Destroys AWS infrastructure
   - ✅ Provides cleanup summary

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

### **Required Secrets**
These are sensitive values that should be stored as GitHub repository secrets:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `AWS_ACCOUNT_ID` | Your AWS account ID (12 digits) | `123456789012` |
| `SSH_PUBLIC_KEY` | Public SSH key for bastion host and nodes | `ssh-rsa AAAAB3NzaC1yc2E...` |
| `SSH_PRIVATE_KEY` | Private SSH key for node communication | `-----BEGIN OPENSSH PRIVATE KEY-----...` |
| `CERT_MANAGER_EMAIL` | Email address for Let's Encrypt certificates (if using SSL) | `admin@yourdomain.com` |

### **Required Variables**
These are non-sensitive values that can be stored as GitHub repository variables:

| Variable Name | Description | Example | Required |
|---------------|-------------|---------|----------|
| `GithubActionsRole` | Name of the IAM role for GitHub Actions | `GithubActionsRole` | ✅ Yes |
| `vpc_cidr` | CIDR block for your VPC | `10.0.0.0/16` | ✅ Yes |
| `node_instance_profile` | Instance profile for K3s nodes | `k3s-node-instance-profile` | ✅ Yes |
| `domain_name` | Your domain name for Route53 DNS management | `tuselis.lt` | ✅ Yes |
| `IPS_TO_BASTION` | IP addresses allowed to access bastion host (comma-separated) | `192.168.1.100/32,10.0.0.0/8` | ✅ Yes |

---

## Workflow Automation

### **Deploy Chain (One-Click Creation):**
```
Manual Trigger: "Create AWS infra, K3S"
        ↓ (on success)
    ┌─────────────────┐
    │                 │
    ▼                 ▼
k3s-deploy.yml   route53-update.yml
    │                 │
    └─────────────────┘
        ↓
   Complete Deployment
```

### **Destroy Chain (One-Click Cleanup):**
```
Manual Trigger: "Destroy K3S Workload"
        ↓ (on success)
    ┌─────────────────┐
    │                 │
    ▼                 ▼
Clean up Jenkins   Destroy Infrastructure
    │                 │
    └─────────────────┘
        ↓
   Complete Cleanup
```

## Author
Edmundas

---

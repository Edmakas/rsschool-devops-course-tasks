# RS School: AWS DevOps 2025Q2 – Task 6 (modules/3_ci-configuration/task_6.md)

This project automates AWS infrastructure provisioning and K3s Kubernetes cluster deployment using Terraform and GitHub Actions. Jenkins is deployed on the cluster with all required Kubernetes prerequisites handled automatically.

---

## Setup Instructions

### 1. Prerequisites
- AWS Account
- GitHub Account
- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Terraform 1.12+](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- Git

### 2. GitHub Actions IAM Role (for CI/CD)
- The Terraform code for creating the `GithubActionsRole` IAM role is located in the `Setup` directory of this repository (`Setup/iam.tf`).
- Set up an OIDC identity provider for GitHub Actions in your AWS account.
- Configure the trust policy to allow GitHub Actions to assume this role securely.

---

### 3. GitHub Repository Secrets and Variables

For GitHub Actions CI/CD to work, you must set the following in your repository:

### **Required Secrets**
These are sensitive values that should be stored as GitHub repository secrets:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `AWS_ACCOUNT_ID` | Your AWS account ID (12 digits) | `123456789012` |
| `SSH_PUBLIC_KEY` | Public SSH key for bastion host and nodes | `ssh-rsa AAAAB3NzaC1yc2E...` |
| `SSH_PRIVATE_KEY` | Private SSH key for connecting to the nodes | `-----BEGIN OPENSSH PRIVATE KEY-----...` |
| `CERT_MANAGER_EMAIL` | Email address for Let's Encrypt certificates (if using SSL) | `admin@yourdomain.com` |


### **Required Variables**
These are non-sensitive values that can be stored as GitHub repository variables:

| Variable Name | Description | Example | Required |
|---------------|-------------|---------|----------|
| `GITHUBACTIONSROLE` | Name of the IAM role for GitHub Actions | `GithubActionsRole` | ✅ Yes |
| `VPC_CIDR` | CIDR block for your VPC | `10.0.0.0/16` | ✅ Yes |
| `NODE_INSTANCE_PROFILE` | Instance profile for K3s nodes | `k3s-node-instance-profile` | ✅ Yes |
| `DOMAIN_NAME` | Your domain name for Route53 DNS management | `tuselis.lt` | ✅ Yes |
| `IPS_TO_BASTION` | IP addresses allowed to access bastion host (comma-separated) | `192.168.1.100/32,10.0.0.0/8` | ✅ Yes |
| `PREFIX` | Prefix for fifferent resources | `rsschool` | ✅ Yes |

---

### 4. **Creating the infrastructure and installing the Flask app**
1. Configure your AWS and GitHub secrets/variables as described in **Required Secrets** and **Required Variables**
2. Set up your Route53 hosted zone and GitHub Actions `DOMAIN_NAME` variable.
3. **Go to GitHub Actions** → **"Create AWS, K3S infra "** → **"Run workflow"** -> **"Manage Flask App Helm Chart"** → **"Run workflow"**
4. **Sit back and watch** - everything happens automatically:
   - ✅ Creates AWS infrastructure (VPC, EC2 instances, security groups)
   - ✅ Deploys K3S cluster, Jenkins, and the Flask app
   - ✅ Updates Route53 DNS records
   - ✅ Provides access information
5. Access to Jenkins and the Flask app is shown in the workflow summary logs

---

### 5. **Destroying Infrastructure:**
1. **Go to GitHub Actions** → **"Destroy K3S Workload"** workflow → **"Run workflow"**
2. **Sit back and watch** - everything is cleaned up automatically

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
│   ├── Mod3_Task4/
│   │   ├── jenkins-values.yaml            # Jenkins Helm chart values (custom config)
│   │   └── Prerequisites/                 # Jenkins prerequisites for K8s
│   │       ├── prerequisites-jenkins-NS.yaml      # Namespace for Jenkins
│   │       ├── prerequisites-jenkins-SC.yaml      # StorageClass for Jenkins PV
│   │       ├── prerequisites-jenkins-SA.yaml      # ServiceAccount, ClusterRole, ClusterRoleBinding for Jenkins
│   │       ├── prerequisites-jenkins-Ingress.yaml # Ingress for Jenkins with dynamic domain
│   │       └── letsencrypt-staging-clusterissuer.yaml # Let's Encrypt staging cluster issuer
│   └── Mod3_Task5/
│       └── flask_app_HelmChart/           # Flask application Helm chart
│           ├── Chart.yaml                 # Helm chart metadata
│           ├── values.yaml                # Default values for Flask app
│           └── templates/                 # Kubernetes templates
│               ├── deployment.yaml        # Flask app deployment
│               ├── service.yaml           # Flask app service
│               └── ingress.yaml           # Flask app ingress
├── JenkinsFiles/                             # Jenkins pipeline scripts
│   └── build-and-push-flask-app.groovy       # Jenkins pipeline: builds, tests, pushes Docker image, and deploys Flask app via Helm
├── .github/
│   └── workflows/
│       ├── k3s-deploy.yml                 # Main CI/CD: infra, prerequisites, Jenkins, DNS
│       ├── k3s-manage.yml                 # Cluster management actions (status, logs, etc.)
│       ├── terraform-plan-create.yml      # Infra provisioning (plan/apply)
│       ├── terraform-destroy.yml          # Infra teardown
│       ├── k3s-destroy-deployments.yml    # K3S workload destruction
│       ├── route53-update.yml             # Manual Route53 DNS record updates
│       ├── cert-manager-deploy.yml        # Cert-Manager deployment workflow
│       └── helm-flask-app.yml             # Flask app Helm chart management (install/upgrade/remove)
└── README.md                              # Project documentation (this file)
```

## Jenkins Pipeline: build-and-push-flask-app.groovy

This Jenkins pipeline automates the CI/CD process for the Flask application. 

### How to Deploy the Jenkins Pipeline

1. **GitHub Pipeline**: Ensure your repository is set up with a GitHub Actions pipeline. This is typically installed automatically as part of the infrastructure setup.
2. **Docker Hub Credentials**: In Jenkins, go to *Manage Jenkins* → *Manage Credentials* and add your Docker Hub username and password as a global credential (type: Username with password, ID: `docker-hub`). This is required for the pipeline to push Docker images.
3. **GitHub Project Configuration**: In your Jenkins job configuration, set the project URL to your GitHub repository and select the option **GitHub hook trigger for GITScm polling**. This allows Jenkins to automatically trigger builds when changes are pushed to GitHub.

The pipeline performs the following stages:

1. **Checkout code** – Retrieves the latest source code from the repository.
2. **Build Docker image** – Builds the Docker image for the Flask app.
3. **Run unit tests** – Executes unit tests inside the built Docker image.
4. **SonarQube scan** – Runs a SonarQube scan for code quality and security analysis.
5. **Push Docker image to registry** – Pushes the built image to Docker Hub.
6. **Deploy Flask app with Helm** – Deploys the Flask app to the Kubernetes cluster using Helm, dynamically setting the image repository, tag, and ingress host.
7. **Verify deployment** – Uses curl to check that the app is accessible at the expected DNS name (http://flask-app.tuselis.lt).
8. **Email notification** – Sends an email notification on build success or failure to the address specified in the `NOTIFY_EMAIL` environment variable.

---
## Jenkins Email Notifications for Pipeline

The Jenkins pipeline in `JenkinsFiles/build-and-push-flask-app.groovy` is configured to send email notifications on build success or failure using the Email Extension Plugin (`emailext`).

### Prerequisites
- **Email Extension Plugin** must be installed in Jenkins.
- Jenkins must be configured with a valid SMTP server (Manage Jenkins → Configure System → Extended E-mail Notification).

### How to Configure the Notification Email
1. **Set the NOTIFY_EMAIL environment variable**
   - Go to your Jenkins job configuration (or global Jenkins configuration).
   - Under **Build Environment** or **Global properties**, add an environment variable:
     - **Name:** `NOTIFY_EMAIL`
     - **Value:** (your recipient email address, e.g., `your@email.com`)

2. **How it works**
   - The pipeline will use the value of `NOTIFY_EMAIL` for the recipient in all email notifications.
   - If the variable is not set, emails will not be sent (the log will show `Sending email to: null`).

---
## Jenkins SonarQube Token Configuration

The Jenkins pipeline in `JenkinsFiles/build-and-push-flask-app.groovy` requires a SonarQube token for code quality analysis.

### Prerequisites
- You must have a valid SonarQube token (generate it from your SonarQube user account).
- The token must be stored in Jenkins as a **Secret Text** credential with the ID `sonarqube-token`.

### How to Configure the SonarQube Token
1. Go to **Manage Jenkins** → **Manage Credentials**.
2. Select the appropriate domain (usually `(global)`).
3. Click **Add Credentials**.
4. For **Kind**, select **Secret text**.
5. **Secret**: Paste your SonarQube token.
6. **ID**: Enter `sonarqube-token` (must match exactly).
7. **Description**: (Optional) e.g., "SonarQube API Token for pipeline analysis".

### How it works
- The pipeline will use the value of the `sonarqube-token` credential for authenticating with SonarQube during the scan stage.
- If the credential is not set, the SonarQube scan stage will fail with a credentials error.

---

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
- **K3S_Manifests/Mod3_Task5/flask_app_HelmChart/**: Flask application Helm chart with deployment, service, and ingress templates
- **JenkinsFiles/build-and-push-flask-app.groovy**: Jenkins pipeline that builds, tests, and pushes the Flask app Docker image, then deploys it to the Kubernetes cluster using Helm. The pipeline sets the image repository, tag, and ingress host dynamically for each deployment.
- **.github/workflows/**: GitHub Actions workflows
  - **k3s-deploy.yml**: Main CI/CD workflow - deploys infra, applies Jenkins prerequisites, installs Jenkins via Helm, manages DNS
  - **k3s-manage.yml**: Cluster management (get status, logs, restart Jenkins, etc.)
  - **terraform-plan-create.yml**: Infrastructure provisioning (plan/apply)
  - **terraform-destroy.yml**: Infrastructure teardown with Route53 cleanup
  - **k3s-destroy-deployments.yml**: K3S workload and Jenkins destruction
  - **route53-update.yml**: Manual Route53 DNS record updates
  - **cert-manager-deploy.yml**: Cert-Manager deployment for SSL certificate management
  - **helm-flask-app.yml**: Flask application Helm chart management (install, upgrade, remove) with access information

---

## Author
Edmundas

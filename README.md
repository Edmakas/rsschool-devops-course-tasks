# AWS DevOps 2025Q2 Course Tasks

## Description
This repository contains the implementation of tasks for the AWS DevOps 2025Q2 course at Rolling Scopes School. The repository focuses on setting up AWS infrastructure using Terraform and implementing CI/CD practices with GitHub Actions.


## Prerequisites
- AWS CLI 2
- Terraform 1.12+
- Git
- GitHub Account
- AWS Account

## Setup Instructions

### 1. Install Required Tools

#### AWS CLI Installation
Follow the official instructions to install AWS CLI 2:
```bash
# For Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

#### Terraform Installation
Install Terraform 1.6 or higher:
```bash
# Using tfenv (recommended)
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bashrc
tfenv install latest
tfenv use latest
```

### 2. AWS Configuration

#### IAM User Setup
1. Create a new IAM user with the following policies:
   - AmazonEC2FullAccess
   - AmazonRoute53FullAccess
   - AmazonS3FullAccess
   - IAMFullAccess
   - AmazonVPCFullAccess
   - AmazonSQSFullAccess
   - AmazonEventBridgeFullAccess

2. Configure MFA for both the new user and root user
3. Generate Access Key ID and Secret Access Key

#### AWS CLI Configuration
```bash
aws configure
# Enter your Access Key ID
# Enter your Secret Access Key
# Enter your preferred region
# Enter your preferred output format (json recommended)
```

Verify the configuration:
```bash
aws ec2 describe-instance-types --instance-types t4g.nano
```

### 3. Terraform State Configuration

1. Create an S3 bucket for Terraform states:
```bash
aws s3api create-bucket \
    --bucket your-terraform-state-bucket \
    --region your-region
```

2. Configure Terraform backend in your configuration:
```hcl
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "terraform.tfstate"
    region = "your-region"
  }
}
```

### 4. GitHub Actions IAM Role (Additional Task)

1. Create IAM role `GithubActionsRole` with the same permissions as the IAM user
2. Configure Identity Provider and Trust policies for GitHub Actions
3. Update the role with appropriate trust relationships

### 5. GitHub Actions Workflow

The repository includes a GitHub Actions workflow with three jobs:
- `terraform-check`: Format checking using `terraform fmt`
- `terraform-plan`: Planning deployments using `terraform plan`
- `terraform-apply`: Deploying changes using `terraform apply -auto-approve`

The workflow runs on:
- Pull requests to main, develop, and task_* branches
- Pushes to main, develop, and task_* branches

Each job uses:
- Terraform version ~> 1.12.0
- AWS credentials configured via IAM role
- Working directory set to Infrastructure folder

## Project Structure
```
.
├── Infrastructure/         # Terraform infrastructure code
│   ├── main.tf            # Main Terraform configuration
│   ├── variables.tf       # Variable definitions
│   └── s3-test.tf         # S3 bucket configuration
├── Setup/                 # Setup and configuration files
│   ├── main.tf            # Main Terraform configuration for setup
│   ├── variables.tf       # Variable definitions for setup
│   └── iam.tf             # IAM roles and policies configuration
├── .github/              # GitHub specific configurations
│   └── workflows/        # GitHub Actions workflows
│       ├── terraform-create.yml  # Workflow for creating resources
│       └── terraform-destroy.yml # Workflow for destroying resources
├── .gitignore           # Git ignore rules
└── README.md            # This file
```

## Author
Edmundas

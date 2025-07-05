# K3s Cluster Management with GitHub Actions

This directory contains the configuration and workflows for managing your K3s cluster on EC2 through GitHub Actions.

## GitHub Actions Workflows

### 1. Deploy to K3s Cluster (`k3s-deploy.yml`)

This workflow automatically deploys applications to your K3s cluster when you push to main, develop, or task_* branches.

**What it does:**
- Connects to your EC2 instances using SSH for IP discovery
- Retrieves the K3s configuration from AWS Parameter Store
- Deploys Jenkins using Helm with your custom values
- Applies any additional Kubernetes manifests
- Provides access information in the workflow summary

**Triggers:**
- Push to main, develop, or task_* branches
- Pull requests
- Manual trigger (workflow_dispatch)

### 2. Manage K3s Cluster (`k3s-manage.yml`)

This workflow allows you to perform various management tasks on your K3s cluster.

**Available Actions:**
- `status`: Get overall cluster status (nodes, pods, services)
- `get-pods`: List all pods across all namespaces
- `get-nodes`: Get detailed node information
- `get-services`: List all services
- `get-logs`: Get Jenkins pod logs
- `restart-jenkins`: Restart the Jenkins deployment
- `apply-manifests`: Apply Kubernetes manifests from the K3S_Manifests directory

**Usage:**
1. Go to the Actions tab in your GitHub repository
2. Select "Manage K3s Cluster"
3. Click "Run workflow"
4. Choose the action you want to perform
5. Click "Run workflow"

## Prerequisites

Make sure you have the following GitHub secrets configured:

- `AWS_ACCOUNT_ID`: Your AWS account ID
- `SSH_PRIVATE_KEY`: Private SSH key for accessing EC2 instances
- `SSH_PUBLIC_KEY`: Public SSH key for accessing EC2 instances

And the following GitHub variables:

- `GithubActionsRole`: IAM role name for GitHub Actions
- `vpc_cidr`: VPC CIDR block
- `IPS_TO_BASTION`: Allowed IPs for bastion access

## Accessing Your Cluster

### Jenkins Access
- **URL**: `http://<master-node-ip>:30111`
- **Username**: `admin`
- **Password**: Check the deployment logs in GitHub Actions

### SSH Access
```bash
# Connect to master node
ssh ubuntu@<master-node-ip>

# Connect to worker node
ssh ubuntu@<worker-node-ip>
```

### Direct kubectl Access
1. Get the K3s configuration from Parameter Store:
```bash
aws ssm get-parameter \
  --name "/rsschool/k3s-yaml" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text > k3s-config.yaml
export KUBECONFIG=k3s-config.yaml
kubectl get nodes
```

## Jenkins Configuration

The Jenkins deployment uses the configuration in `Mod3_Task4/jenkins-values.yaml` which includes:

- NodePort service on port 30111
- Kubernetes plugin for dynamic agent provisioning
- Git plugin for source code management
- Workflow aggregator for pipeline support
- Configuration as Code plugin

## Troubleshooting

### Common Issues

1. **SSH Connection Failed**
   - Verify your SSH keys are correctly set in GitHub secrets
   - Check that the EC2 instances are running
   - Ensure security groups allow SSH access from GitHub Actions

2. **K3s Not Ready**
   - The workflow waits for K3s to be ready automatically
   - If it times out, check the EC2 instance logs

3. **Jenkins Deployment Failed**
   - Check the Helm deployment logs
   - Verify the jenkins-values.yaml file is valid
   - Ensure the jenkins namespace exists

### Getting Help

1. Check the workflow logs in GitHub Actions
2. SSH to the master node and check K3s status:
   ```bash
   kubectl get nodes
   kubectl get pods --all-namespaces
   ```
3. Check Jenkins logs:
   ```bash
   kubectl logs -n jenkins deployment/jenkins
   ```

## Security Notes

- The workflows use AWS IAM roles for authentication
- SSH keys are stored as GitHub secrets (used only for IP discovery)
- K3s configuration is retrieved securely from AWS Parameter Store
- Jenkins is exposed on a NodePort (30111) - consider using an ingress controller for production

## Next Steps

1. **Set up Ingress Controller**: Consider deploying an ingress controller for better service exposure
2. **Configure Monitoring**: Add Prometheus and Grafana for cluster monitoring
3. **Backup Strategy**: Implement regular backups of Jenkins data and K3s configuration
4. **Security Hardening**: Review and enhance security configurations 

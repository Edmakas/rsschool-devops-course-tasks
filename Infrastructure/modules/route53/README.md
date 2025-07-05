# Route53 Module

This module manages DNS records for the Jenkins deployment using AWS Route53.

## Features

- Creates A record for `jenkins.{domain_name}` pointing to the Jenkins server IP
- Automatically updates DNS when the infrastructure is deployed
- Supports manual DNS updates via GitHub Actions workflow
- Uses dynamic domain configuration from GitHub Actions variables

## Usage

### Automatic DNS Management

The Route53 module is automatically included in the main infrastructure deployment. It will:

1. Create the `jenkins.{domain_name}` A record (e.g., `jenkins.tuselis.lt`)
2. Point it to the K3s master node's public IP
3. Update the record whenever the infrastructure is redeployed
4. Use the domain name from GitHub Actions variables

### Manual DNS Updates

If you need to update the DNS record manually (e.g., if the IP address changes), you can:

1. Use the GitHub Actions workflow: `Update Route53 DNS Records`
2. Provide the new Jenkins server IP address
3. The workflow will update the DNS record automatically

### Variables

- `domain_name`: The domain name for the hosted zone (set via GitHub Actions variable `domain_name`)
- `jenkins_ip_address`: The public IP address of the Jenkins server

### Outputs

- `jenkins_dns_name`: The DNS name for Jenkins (e.g., `jenkins`)
- `jenkins_dns_fqdn`: The fully qualified domain name for Jenkins (e.g., `jenkins.tuselis.lt`)

## Prerequisites

1. A Route53 hosted zone for your domain (e.g., `tuselis.lt`) must exist in your AWS account
2. The AWS credentials must have permissions to manage Route53 records
3. The domain must be properly configured with nameservers
4. GitHub Actions variable `domain_name` must be set (e.g., `tuselis.lt`)

## Access URLs

After deployment, Jenkins will be accessible at:
- `http://jenkins.{domain_name}` (via domain, e.g., `http://jenkins.tuselis.lt`)
- `http://<server-ip>:30111` (direct IP access) 
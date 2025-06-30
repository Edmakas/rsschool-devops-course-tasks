#!/bin/bash
set -e  # Exit on any error

# Function to log to both console and file
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a /var/log/node2-setup.log
}

# Enable debug logging
exec > >(tee /var/log/node2-setup.log) 2>&1
log "=== Node-2 Setup Started ==="

sudo hostnamectl set-hostname node-2
echo "127.0.1.1 node-2" | sudo tee -a /etc/hosts
sudo apt-get update -y
sudo apt-get install -y netcat-openbsd

# Get master node IP from Terraform template variable
MASTER_IP="${master_ip}"
log "Master node IP: $MASTER_IP"

# Test basic connectivity to master
log "Testing connectivity to master node..."
if ping -c 3 $MASTER_IP; then
  log "Ping to master successful"
else
  log "ERROR: Cannot ping master node"
  exit 1
fi

# Create private key file for SSH access
log "Setting up SSH key..."
mkdir -p /home/ubuntu/.ssh
cat <<EOF > /home/ubuntu/.ssh/id_rsa
${private_key}
EOF
chmod 600 /home/ubuntu/.ssh/id_rsa
chown -R ubuntu:ubuntu /home/ubuntu/.ssh

# Test SSH connectivity to master
log "Testing SSH connectivity to master..."
if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -i /home/ubuntu/.ssh/id_rsa ubuntu@$MASTER_IP "echo 'SSH test successful'"; then
  log "SSH to master successful"
else
  log "ERROR: Cannot SSH to master node"
  exit 1
fi

# Wait for K3s server to be ready by checking if port 6443 is listening
log "Waiting for K3s server to be ready..."
COUNTER=0
until nc -z $MASTER_IP 6443; do
  log "K3s server not ready yet, waiting... (attempt $COUNTER)"
  sleep 10
  COUNTER=$((COUNTER + 1))
  if [ $COUNTER -gt 30 ]; then
    log "ERROR: K3s server not ready after 5 minutes"
    exit 1
  fi
done
log "K3s server is listening on port 6443"

# Additional wait to ensure K3s is fully initialized
log "Waiting additional 30 seconds for K3s to fully initialize..."
sleep 30

# Test if K3s API is responding
log "Testing K3s API connectivity..."
if curl -k -s https://$MASTER_IP:6443/healthz; then
  log "K3s API is responding"
else
  log "WARNING: K3s API not responding, but continuing..."
fi

# Get the token using SSH and verify it's not empty
log "Fetching K3s token via SSH..."
TOKEN=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@$MASTER_IP "sudo cat /var/lib/rancher/k3s/server/node-token")

# Verify token is not empty
if [ -z "$TOKEN" ]; then
  log "ERROR: Token is empty or could not be retrieved"
  log "Retrying token fetch..."
  sleep 10
  TOKEN=$(ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@$MASTER_IP "sudo cat /var/lib/rancher/k3s/server/node-token")
  
  if [ -z "$TOKEN" ]; then
    log "ERROR: Token is still empty after retry. Exiting."
    exit 1
  fi
fi

log "Token retrieved successfully: $${TOKEN:0:10}..."
log "Joining K3s cluster as worker node..."

# Install K3s as worker node
curl -sfL https://get.k3s.io | K3S_URL=https://$MASTER_IP:6443 K3S_TOKEN=$TOKEN sh -

# Wait for K3s agent to start
log "Waiting for K3s agent to start..."
sleep 30

# Check if K3s agent is running
if sudo systemctl is-active --quiet k3s-agent; then
  log "K3s agent is running successfully"
else
  log "ERROR: K3s agent is not running"
  sudo systemctl status k3s-agent
  exit 1
fi

log "=== Node-2 Setup Completed Successfully ==="

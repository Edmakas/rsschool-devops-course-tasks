#!/bin/bash
set -e  # Exit on any error

# Function to log to both console and file
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a /var/log/node1-setup.log
}

# Enable debug logging
exec > >(tee /var/log/node1-setup.log) 2>&1
log "=== Node-1 Setup Started ==="

sudo hostnamectl set-hostname node-1
echo "127.0.1.1 node-1" | sudo tee -a /etc/hosts
sudo apt-get update -y

log "Installing K3s server..."
curl -sfL https://get.k3s.io | sh -

# Create private key file for SSH access
log "Setting up SSH key..."
mkdir -p /home/ubuntu/.ssh
cat <<EOF > /home/ubuntu/.ssh/id_rsa
${private_key}
EOF
chmod 600 /home/ubuntu/.ssh/id_rsa
chown -R ubuntu:ubuntu /home/ubuntu/.ssh

# Wait for K3s to be ready
log "Waiting for K3s to be ready..."
COUNTER=0
until sudo k3s kubectl get nodes; do
  log "K3s not ready yet, waiting... (attempt $COUNTER)"
  sleep 5
  COUNTER=$((COUNTER + 1))
  if [ $COUNTER -gt 60 ]; then
    log "ERROR: K3s not ready after 5 minutes"
    sudo systemctl status k3s
    exit 1
  fi
done

log "K3s server is ready"
log "Node token: $(sudo cat /var/lib/rancher/k3s/server/node-token | cut -c1-10)..."
log "K3s server IP: $(hostname -I | awk '{print $1}')"

# Verify K3s is listening on port 6443
if sudo netstat -tlnp | grep :6443; then
  log "K3s is listening on port 6443"
else
  log "ERROR: K3s is not listening on port 6443"
  exit 1
fi

log "=== Node-1 Setup Completed Successfully ===" 

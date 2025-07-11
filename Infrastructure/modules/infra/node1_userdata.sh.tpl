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

sudo apt-get install -y net-tools
# Install unzip if not present
if ! command -v unzip &> /dev/null; then
  sudo apt-get install -y unzip
fi

# Install AWS CLI v2 if not present
if ! command -v aws &> /dev/null; then
  log "Installing AWS CLI v2..."
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
  unzip -q /tmp/awscliv2.zip -d /tmp
  sudo /tmp/aws/install
  rm -rf /tmp/aws /tmp/awscliv2.zip
fi

# Install Docker if not present
if ! command -v docker &> /dev/null; then
  log "Installing Docker..."
  sudo apt-get update -y
  sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  UBUNTU_CODENAME=$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $UBUNTU_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update -y
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  
  sudo usermod -aG docker ubuntu
  log "Docker installed successfully."
fi

# Get public IP for TLS SAN
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 60")
PUBLIC_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/public-ipv4)
log "Installing K3s server with --tls-san $PUBLIC_IP and --disable traefik..."
curl -sfL https://get.k3s.io | sh -s - server --tls-san $PUBLIC_IP --docker --disable traefik --disable servicelb


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

# Wait for k3s.yaml to exist
log "Waiting for /etc/rancher/k3s/k3s.yaml to be created..."
while [ ! -f /etc/rancher/k3s/k3s.yaml ]; do
  sleep 2
done

# Copy k3s.yaml to /tmp and replace server address with public IP
sudo cp /etc/rancher/k3s/k3s.yaml /tmp/k3s.yaml
log "Replacing server address in /tmp/k3s.yaml with public IP: $PUBLIC_IP"
sudo sed -i "s|server: https://127.0.0.1:6443|server: https://$PUBLIC_IP:6443|" /tmp/k3s.yaml

log "Uploading /tmp/k3s.yaml to SSM Parameter Store..."
aws ssm put-parameter \
  --name "/${prefix}/k3s-yaml" \
  --type "SecureString" \
  --value "$(sudo cat /tmp/k3s.yaml)" \
  --overwrite \
  --region ${region}

# --- Add custom registries.yaml for ECR mirror and auth ---
# log "Creating /etc/rancher/k3s/registries.yaml for ECR mirror and auth..."
# sudo tee /etc/rancher/k3s/registries.yaml > /dev/null <<EOF
# mirrors:
#   "033534701841.dkr.ecr.us-west-2.amazonaws.com":
#     endpoint:
#       - "https://033534701841.dkr.ecr.us-west-2.amazonaws.com"

# configs:
#   "033534701841.dkr.ecr.us-west-2.amazonaws.com":
#     auth:
#       username: AWS
#       password: "$(aws ecr get-login-password --region us-west-2)"
# EOF

# log "Restarting k3s to apply new registry configuration..."
# sudo systemctl restart k3s

# log "=== Node-1 Setup Completed Successfully ===" 

# # --- ECR Secret Refresh Logic ---
# log "Setting up periodic ECR secret refresh via systemd timer..."

# cat <<'EOF' | sudo tee /usr/local/bin/refresh-ecr-secret.sh > /dev/null
# #!/bin/bash
# kubectl create secret docker-registry ecr-creds \
#   --docker-server=033534701841.dkr.ecr.us-west-2.amazonaws.com \
#   --docker-username=AWS \
#   --docker-password="$(aws ecr get-login-password --region us-west-2)" \
#   --dry-run=client -o yaml | kubectl apply -f -
# EOF

# sudo chmod +x /usr/local/bin/refresh-ecr-secret.sh

# cat <<'EOF' | sudo tee /etc/systemd/system/refresh-ecr-secret.service > /dev/null
# [Unit]
# Description=Refresh AWS ECR Kubernetes Secret

# [Service]
# Type=oneshot
# ExecStart=/usr/local/bin/refresh-ecr-secret.sh
# EOF

# cat <<'EOF' | sudo tee /etc/systemd/system/refresh-ecr-secret.timer > /dev/null
# [Unit]
# Description=Run refresh-ecr-secret every 6 hours

# [Timer]
# OnBootSec=5min
# OnUnitActiveSec=6h

# [Install]
# WantedBy=timers.target
# EOF

# sudo systemctl daemon-reload
# sudo systemctl enable --now refresh-ecr-secret.timer
# log "ECR secret refresh systemd timer enabled." 

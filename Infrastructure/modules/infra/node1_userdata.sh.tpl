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

  UBUNTU_CODENAME=$(. /etc/os-release && echo "$${UBUNTU_CODENAME:-$${VERSION_CODENAME}}")
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $UBUNTU_CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update -y
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo usermod -aG docker ubuntu
  log "Docker installed successfully."
fi

# Install Node Exporter
log "Installing Node Exporter..."
NODE_EXPORTER_VERSION="${NODE_EXPORTER_VERSION}"
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
if [ -f node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz ]; then
  tar xvfz node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
  sudo mv node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/node_exporter
  sudo chown root:root /usr/local/bin/node_exporter
  sudo chmod 755 /usr/local/bin/node_exporter
  sudo useradd -rs /bin/false node_exporter || true

  # Create systemd service
  cat <<EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl start node_exporter
  sudo systemctl enable node_exporter
  log "Node Exporter installed and started."
else
  log "Failed to download Node Exporter."
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

#!/bin/bash
hostnamectl set-hostname bastion
echo "127.0.1.1 bastion" >> /etc/hosts
apt-get update -y
apt-get install -y curl apt-transport-https ca-certificates gnupg lsb-release openssh-client

# Install kubectl
KUBECTL_VERSION="v1.30.1"
curl -LO "https://dl.k8s.io/release/$${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Create private key file
mkdir -p /home/ubuntu/.ssh
cat <<EOF > /home/ubuntu/.ssh/id_rsa
${private_key}
EOF
chmod 600 /home/ubuntu/.ssh/id_rsa
chown -R ubuntu:ubuntu /home/ubuntu/.ssh

# Wait for master node
sleep 60
MASTER_IP="${master_ip}"

ssh -o StrictHostKeyChecking=no -i /home/ubuntu/.ssh/id_rsa ubuntu@$MASTER_IP "sudo cat /etc/rancher/k3s/k3s.yaml" > k3s.yaml
sed -i "s/127.0.0.1/$MASTER_IP/" /home/ubuntu/k3s.yaml
chown ubuntu:ubuntu /home/ubuntu/k3s.yaml
echo 'export KUBECONFIG=/home/ubuntu/k3s.yaml' >> /home/ubuntu/.bashrc

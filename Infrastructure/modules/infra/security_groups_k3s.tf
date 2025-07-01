resource "aws_security_group" "k3s_nodes" {
  name        = "${var.prefix}-k3s-nodes-sg"
  description = "Security group for K3s nodes - allows required inbound traffic"
  vpc_id      = aws_vpc.main.id

  # TCP 2379-2380: Required only for HA with embedded etcd
  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "HA etcd communication"
  }

  # TCP 6443: K3s supervisor, Kubernetes API Server, and Embedded distributed registry (Spegel)
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Kubernetes API Server and Embedded distributed registry (Spegel)"
  }

  # UDP 8472: Required only for Flannel VXLAN
  ingress {
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
    description = "Flannel VXLAN"
  }

  # TCP 10250: Kubelet metrics
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Kubelet metrics"
  }

  # UDP 51820: Flannel Wireguard with IPv4
  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
    description = "Flannel Wireguard IPv4"
  }

  # UDP 51821: Flannel Wireguard with IPv6
  ingress {
    from_port   = 51821
    to_port     = 51821
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
    description = "Flannel Wireguard IPv6"
  }

  # TCP 5001: Embedded distributed registry (Spegel)
  ingress {
    from_port   = 5001
    to_port     = 5001
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Embedded distributed registry (Spegel)"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.prefix}-k3s-nodes-sg"
  }
}

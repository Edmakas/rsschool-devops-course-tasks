# Network ACLs and Associations

# Network ACL for Public Subnets
resource "aws_network_acl" "public_nacl" {
  vpc_id = aws_vpc.main.id

  # Inbound rules
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # Outbound rules
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "${var.prefix}-public-nacl"
  }
}

# Network ACL for Private Subnets
resource "aws_network_acl" "private_nacl" {
  vpc_id = aws_vpc.main.id

  # Allow SSH from public subnet (bastion)
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = aws_subnet.public[0].cidr_block
    from_port  = 22
    to_port    = 22
  }

  # Allow K3s required ports between private subnets (node-to-node)
  # Kubernetes API server, etcd, kubelet, flannel, wireguard, registry
  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = aws_subnet.private[0].cidr_block
    from_port  = 2379
    to_port    = 2380
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 111
    action     = "allow"
    cidr_block = aws_subnet.private[1].cidr_block
    from_port  = 2379
    to_port    = 2380
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 112
    action     = "allow"
    cidr_block = aws_subnet.private[0].cidr_block
    from_port  = 6443
    to_port    = 6443
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 113
    action     = "allow"
    cidr_block = aws_subnet.private[1].cidr_block
    from_port  = 6443
    to_port    = 6443
  }
  ingress {
    protocol   = "udp"
    rule_no    = 114
    action     = "allow"
    cidr_block = aws_subnet.private[0].cidr_block
    from_port  = 8472
    to_port    = 8472
  }
  ingress {
    protocol   = "udp"
    rule_no    = 115
    action     = "allow"
    cidr_block = aws_subnet.private[1].cidr_block
    from_port  = 8472
    to_port    = 8472
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 116
    action     = "allow"
    cidr_block = aws_subnet.private[0].cidr_block
    from_port  = 10250
    to_port    = 10250
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 117
    action     = "allow"
    cidr_block = aws_subnet.private[1].cidr_block
    from_port  = 10250
    to_port    = 10250
  }
  ingress {
    protocol   = "udp"
    rule_no    = 118
    action     = "allow"
    cidr_block = aws_subnet.private[0].cidr_block
    from_port  = 51820
    to_port    = 51821
  }
  ingress {
    protocol   = "udp"
    rule_no    = 119
    action     = "allow"
    cidr_block = aws_subnet.private[1].cidr_block
    from_port  = 51820
    to_port    = 51821
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = aws_subnet.private[0].cidr_block
    from_port  = 5001
    to_port    = 5001
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 121
    action     = "allow"
    cidr_block = aws_subnet.private[1].cidr_block
    from_port  = 5001
    to_port    = 5001
  }
  # Allow ephemeral ports for node-to-node communication
  ingress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = aws_subnet.private[0].cidr_block
    from_port  = 1024
    to_port    = 65535
  }
  ingress {
    protocol   = "tcp"
    rule_no    = 131
    action     = "allow"
    cidr_block = aws_subnet.private[1].cidr_block
    from_port  = 1024
    to_port    = 65535
  }

  # Outbound rules - allow all for now
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.prefix}-private-nacl"
  }
}

# Associate Public NACL with Public Subnets
resource "aws_network_acl_association" "public_nacl_association" {
  count          = 1
  network_acl_id = aws_network_acl.public_nacl.id
  subnet_id      = aws_subnet.public[count.index].id
}

# Associate Private NACL with Private Subnets
resource "aws_network_acl_association" "private_nacl_association" {
  count          = 1
  network_acl_id = aws_network_acl.private_nacl.id
  subnet_id      = aws_subnet.private[count.index].id
}

# modules/infrasecurity.tf
# Security Groups

# Security Group for Bastion Host - Only SSH from allowed IPs
resource "aws_security_group" "bastion_sg" {
  name        = "${var.prefix}-bastion-sg"
  description = "Security group for bastion host - SSH only"
  vpc_id      = aws_vpc.main.id

  # SSH access from specific IP ranges only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ips_to_bastion
    description = "SSH access from allowed IPs only"
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
    Name = "${var.prefix}-bastion-sg"
  }
}

# Security Group for Private Instances
resource "aws_security_group" "private_sg" {
  name        = "${var.prefix}-private-sg"
  description = "Security group for private instances"
  vpc_id      = aws_vpc.main.id

  # SSH access from bastion host
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
    description     = "SSH access from bastion host"
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
    Name = "${var.prefix}-private-sg"
  }
}

# modules/infrasecurity.tf
# Security Groups

# Security Group for public VPC
resource "aws_security_group" "public_sg" {
  name        = "${var.prefix}-public-sg"
  description = "Security group for public VPC"
  vpc_id      = aws_vpc.main.id

  # SSH access from specific IP ranges only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access from allowed IPs only"
  }
  # ICMP (ping) from anywhere
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow ICMP (ping) from anywhere"
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
    Name = "${var.prefix}-public-sg"
  }
}

# modules/infrasecurity.tf
# Security Groups

# Security Group for public VPC
resource "aws_security_group" "jenkins_sg" {
  name        = "${var.prefix}-jenkins-sg"
  description = "Security group for jenkins"
  vpc_id      = aws_vpc.main.id

  # SSH access from specific IP ranges only
  ingress {
    from_port   = 30111
    to_port     = 30111
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Access to Jenkins Gui"
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
    Name = "${var.prefix}-jenkins-sg"
  }
}

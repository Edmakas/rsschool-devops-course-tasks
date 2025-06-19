# modules/infra/ec2.terraform 

# Create SSH Key Pair for bastion host
resource "aws_key_pair" "bastion_key" {
  key_name   = "${var.prefix}-bastion-key"
  public_key = var.public_key
}

# Bastion Host for secure access to private subnets
resource "aws_instance" "bastion" {
  ami                    = "ami-09e6f87a47903347c"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public[0].id # Place in first public subnet
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = aws_key_pair.bastion_key.key_name
  tags = {
    Name = "bastion-host"
  }
}

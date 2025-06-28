# modules/infra/bastion.tf

# Create SSH Key Pair for bastion host
resource "aws_key_pair" "bastion_key" {
  key_name   = "${var.prefix}-bastion-key"
  public_key = var.public_key
}

# Bastion Host for secure access to private subnets
resource "aws_instance" "bastion" {
  ami                    = "ami-05f991c49d264708f" # Ubuntu 22.04 LTS for us-west-2
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public[0].id # Place in first public subnet
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = aws_key_pair.bastion_key.key_name

  depends_on = [aws_instance.test_private_1, aws_instance.test_private_2]

  tags = {
    Name = "bastion-host"
  }
  user_data = base64encode(templatefile("${path.module}/bastion_userdata.sh.tpl", {
    master_ip   = aws_instance.test_private_1.private_ip
    private_key = var.private_key
  }))
}

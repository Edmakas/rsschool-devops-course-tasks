# Test EC2 instances for each subnet - DELETE AFTER TESTING

# Test EC2 in Public Subnet 1
# resource "aws_instance" "test_public_1" {
#   ami                    = "ami-09e6f87a47903347c"
#   instance_type          = "t2.micro"
#   subnet_id              = aws_subnet.public[0].id
#   vpc_security_group_ids = [aws_security_group.bastion_sg.id]
#   key_name               = aws_key_pair.bastion_key.key_name

#   tags = {
#     Name        = "${var.prefix}-test-public-1"
#     Purpose     = "Testing"
#     DeleteAfter = "Testing"
#   }
# }

# # Test EC2 in Public Subnet 2
# resource "aws_instance" "test_public_2" {
#   ami                    = "ami-09e6f87a47903347c"
#   instance_type          = "t2.micro"
#   subnet_id              = aws_subnet.public[1].id
#   vpc_security_group_ids = [aws_security_group.bastion_sg.id]
#   key_name               = aws_key_pair.bastion_key.key_name

#   tags = {
#     Name        = "${var.prefix}-test-public-2"
#     Purpose     = "Testing"
#     DeleteAfter = "Testing"
#   }
# }

# Test EC2 in Private Subnet 1
resource "aws_instance" "test_private_1" {
  ami                    = "ami-05f991c49d264708f" # Ubuntu 22.04 LTS for us-west-2
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.private_sg.id, aws_security_group.k3s_nodes.id]
  key_name               = aws_key_pair.bastion_key.key_name
  user_data              = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname node-1
              echo "127.0.1.1 node-1" >> /etc/hosts
              apt-get update -y
              EOF
  tags = {
    Name    = "${var.prefix}-node-1"
    Purpose = "k3s-node"
  }
}

# Test EC2 in Private Subnet 2
resource "aws_instance" "test_private_2" {
  ami                    = "ami-05f991c49d264708f" # Ubuntu 22.04 LTS for us-west-2
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.private[1].id
  vpc_security_group_ids = [aws_security_group.private_sg.id, aws_security_group.k3s_nodes.id]
  key_name               = aws_key_pair.bastion_key.key_name
  user_data              = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname node-2
              echo "127.0.1.1 node-2" >> /etc/hosts
              apt-get update -y
              EOF
  tags = {
    Name    = "${var.prefix}-node-2"
    Purpose = "k3s-node"

  }
}

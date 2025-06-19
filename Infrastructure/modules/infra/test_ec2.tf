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
  ami                    = "ami-0c65adc9a5c1b5d7c" # Ubuntu 22.04 LTS for us-west-2
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name               = aws_key_pair.bastion_key.key_name
  user_data              = <<-EOF
      #!/bin/bash
      # Set password for ubuntu user
      echo 'ec2-user:SeAkMApxDAjTEkAdVq9q' | chpasswd

      # Allow password authentication
      sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
      sed -i 's/^ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/' /etc/ssh/sshd_config

      # Restart SSH service
      systemctl restart sshd
    EOF
  tags = {
    Name        = "${var.prefix}-test-private-1"
    Purpose     = "Testing"
    DeleteAfter = "Testing"
  }
}

# # Test EC2 in Private Subnet 2
resource "aws_instance" "test_private_2" {
  ami                    = "ami-0c65adc9a5c1b5d7c" # Ubuntu 22.04 LTS for us-west-2
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private[1].id
  vpc_security_group_ids = [aws_security_group.private_sg.id]
  key_name               = aws_key_pair.bastion_key.key_name

  tags = {
    Name        = "${var.prefix}-test-private-2"
    Purpose     = "Testing"
    DeleteAfter = "Testing"
  }
}

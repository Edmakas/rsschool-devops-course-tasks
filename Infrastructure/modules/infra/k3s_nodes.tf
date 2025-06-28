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
  ami                    = "ami-05f991c49d264708f"
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.private[0].id
  vpc_security_group_ids = [aws_security_group.private_sg.id, aws_security_group.k3s_nodes.id]
  key_name               = aws_key_pair.bastion_key.key_name

  user_data = base64encode(templatefile("${path.module}/node1_userdata.sh.tpl", {
    private_key = var.private_key
  }))

  tags = {
    Name    = "${var.prefix}-node-1"
    Purpose = "k3s-node"
  }
}

# Test EC2 in Private Subnet 2
resource "aws_instance" "test_private_2" {
  ami                    = "ami-05f991c49d264708f"
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.private[1].id
  vpc_security_group_ids = [aws_security_group.private_sg.id, aws_security_group.k3s_nodes.id]
  key_name               = aws_key_pair.bastion_key.key_name

  depends_on = [aws_instance.test_private_1]

  user_data = base64encode(templatefile("${path.module}/node2_userdata.sh.tpl", {
    master_ip   = aws_instance.test_private_1.private_ip
    private_key = var.private_key
  }))

  tags = {
    Name    = "${var.prefix}-node-2"
    Purpose = "k3s-node"

  }
}

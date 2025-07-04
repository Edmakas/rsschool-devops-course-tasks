# node-1 EC2 in Public  Subnet

resource "aws_instance" "node-1" {
  # ami                    = "ami-05f991c49d264708f"
  ami                    = "ami-0a1b2c3d4e5f67890"
  instance_type          = "t3.large"
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.public_sg.id, aws_security_group.k3s_nodes.id, aws_security_group.jenkins_sg.id]
  key_name               = aws_key_pair.ssh_public_key.key_name
  iam_instance_profile   = "cif-k3s-node-instance-profile"

  user_data = base64encode(templatefile("${path.module}/node1_userdata.sh.tpl", {
    private_key = var.private_key,
    prefix      = var.prefix,
    region      = var.aws_region
  }))

  tags = {
    Name    = "${var.prefix}-node-1"
    Purpose = "k3s-node"
  }
}

#  node-2 EC2 in Public  Subnet 1
# resource "aws_instance" "node-2" {
#   ami                    = "ami-05f991c49d264708f"
#   instance_type          = "t2.medium"
#   subnet_id              = aws_subnet.public[0].id
#   vpc_security_group_ids = [aws_security_group.public_sg.id, aws_security_group.k3s_nodes.id, aws_security_group.jenkins_sg.id]
#   key_name               = aws_key_pair.ssh_public_key.key_name

#   depends_on = [aws_instance.node-1]

#   user_data = base64encode(templatefile("${path.module}/node2_userdata.sh.tpl", {
#     master_ip   = aws_instance.node-1.private_ip
#     private_key = var.private_key
#   }))

#   tags = {
#     Name    = "${var.prefix}-node-2"
#     Purpose = "k3s-node"

#   }
# }

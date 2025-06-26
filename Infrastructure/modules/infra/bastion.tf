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
  tags = {
    Name = "bastion-host"
  }

  user_data = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname bastion
              echo "127.0.1.1 bastion" >> /etc/hosts
              apt-get update -y
              curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
              sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
              EOF

  # Wait for the instance to be ready before running provisioners
  # provisioner "remote-exec" {
  #   inline = ["echo 'Instance is ready'"]

  #   connection {
  #     type        = "ssh"
  #     user        = "ubuntu"
  #     private_key = file("/home/ubuntu/.ssh/bastion_aws_test_rsa")
  #     host        = self.public_ip
  #   }
  # }

  # Copy the public key file to the bastion host
  # provisioner "file" {
  #   source      = "/home/ubuntu/.ssh/bastion_aws_test_rsa"
  #   destination = "/home/ubuntu/.ssh/bastion_aws_test_rsa"

  #   connection {
  #     type        = "ssh"
  #     user        = "ubuntu"
  #     private_key = file("/home/ubuntu/.ssh/bastion_aws_test_rsa")
  #     host        = self.public_ip
  #   }
  # }

  # Set correct permissions on the private key
  #   provisioner "remote-exec" {
  #     inline = [
  #       "chmod 400 /home/ubuntu/.ssh/bastion_aws_test_rsa"
  #     ]

  #     connection {
  #       type        = "ssh"
  #       user        = "ubuntu"
  #       private_key = file("/home/ubuntu/.ssh/bastion_aws_test_rsa")
  #       host        = self.public_ip
  #     }
  #   }
}

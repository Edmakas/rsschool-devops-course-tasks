# modules/infra/ssh_keys.tf

# Create SSH Key Pair for bastion host
resource "aws_key_pair" "ssh_public_key" {
  key_name   = "${var.prefix}-ssh-public-key"
  public_key = var.public_key
}

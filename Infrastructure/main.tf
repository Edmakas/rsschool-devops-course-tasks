# Root Main.tf

module "infra" {
  source                = "./modules/infra"
  vpc_cidr              = var.vpc_cidr
  prefix                = var.prefix
  public_key            = var.public_key
  private_key           = var.private_key
  node_instance_profile = "k3s-node-instance-profile"
  aws_region            = var.aws_region
}

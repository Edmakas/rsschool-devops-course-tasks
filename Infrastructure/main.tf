# Root Main.tf

module "infra" {
  source         = "./modules/infra"
  vpc_cidr       = var.vpc_cidr
  ips_to_bastion = var.ips_to_bastion
  prefix         = var.prefix
  public_key     = var.public_key
}

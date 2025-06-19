# Root Main.tf

module "infra" {
  source     = "./modules/infra"
  vpc_cidr   = var.vpc_cidr
  prefix     = var.prefix
  public_key = var.public_key
}

# Root Main.tf

module "infra" {
  source                = "./modules/infra"
  vpc_cidr              = var.vpc_cidr
  prefix                = var.prefix
  public_key            = var.public_key
  private_key           = var.private_key
  node_instance_profile = "cif-k3s-node-instance-profile"
  aws_region            = var.aws_region
}

# Route53 module for DNS management
module "route53" {
  source            = "./modules/route53"
  domain_name       = var.domain_name
  jenkins_ip_address = var.jenkins_ip_address != null ? var.jenkins_ip_address : module.infra.node-1_public_ip
}

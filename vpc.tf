module "vpc" {
  source                 = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=v5.1.1"
  name                   = "funnela-${var.account}"
  cidr                   = "10.${var.subnet_number}.0.0/16"
  azs                    = var.azs
  private_subnets        = ["10.${var.subnet_number}.96.0/19", "10.${var.subnet_number}.128.0/19", "10.${var.subnet_number}.160.0/19"]
  public_subnets         = ["10.${var.subnet_number}.0.0/19", "10.${var.subnet_number}.32.0/19", "10.${var.subnet_number}.64.0/19"]
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = true
  enable_dns_support     = true

  vpc_tags = {
    Name = "funnela-${var.account}"
  }
  public_subnet_tags = {
    Type = "public"
  }
  private_subnet_tags = {
    Type = "private"
  }
}

data "aws_subnet" "first_az_private_subnet" {
  filter {
    name   = "tag:Name"
    values = ["funnela-${var.account}-private-${var.azs[0]}"]
  }
  depends_on = [
    module.vpc
  ]
}

data "aws_subnet" "first_az_public_subnet" {
  filter {
    name   = "tag:Name"
    values = ["funnela-${var.account}-public-${var.azs[0]}"]
  }
  depends_on = [
    module.vpc
  ]
}

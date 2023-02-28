data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_subnet" "private_subnets_a" {
  vpc_id = var.vpc_id
  tags = {
    "Name" = "hmpps-${var.environment}-general-private-${data.aws_region.current.name}a"
  }
}

data "aws_subnet" "private_subnets_b" {
  vpc_id = var.vpc_id
  tags = {
    "Name" = "hmpps-${var.environment}-general-private-${data.aws_region.current.name}b"
  }
}

data "aws_subnet" "private_subnets_c" {
  vpc_id = var.vpc_id
  tags = {
    "Name" = "hmpps-${var.environment}-general-private-${data.aws_region.current.name}c"
  }
}

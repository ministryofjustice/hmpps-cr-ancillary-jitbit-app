terraform {
  backend "s3" {
    encrypt = true
    key     = "terraform.tfstate"
    region  = "eu-west-2"
  }
}

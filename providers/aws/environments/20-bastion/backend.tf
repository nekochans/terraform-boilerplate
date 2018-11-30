terraform {
  required_version = "=0.11.10"

  backend "s3" {
    bucket  = "dev-nekochans-tfstate"
    key     = "bastion/terraform.tfstate"
    region  = "ap-northeast-1"
    profile = "nekochans-dev"
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"

  config {
    bucket  = "dev-nekochans-tfstate"
    key     = "env:/${terraform.env}/network/terraform.tfstate"
    region  = "ap-northeast-1"
    profile = "nekochans-dev"
  }
}

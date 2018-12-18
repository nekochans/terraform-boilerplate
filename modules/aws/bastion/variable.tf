variable "bastion" {
  type = "map"

  default = {
    default.name          = "prod-bastion"
    stg.name              = "stg-bastion"
    dev.name              = "dev-bastion"
    qa.name               = "qa-bastion"
    default.ami           = "ami-00a5245b4816c38e6"
    default.instance_type = "t3.micro"
    default.volume_type   = "gp2"
    default.volume_size   = "30"
  }
}

variable "ssh_public_key_path" {
  type    = "string"
  default = ""
}

variable "vpc" {
  type = "map"

  default = {}
}

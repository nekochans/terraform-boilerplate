module "bastion" {
  source              = "../../../../modules/aws/bastion"
  ssh_public_key_path = "${var.ssh_public_key_path}"
  vpc                 = "${data.terraform_remote_state.network.vpc}"
}

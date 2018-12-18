resource "aws_security_group" "bastion" {
  name        = "${lookup(var.bastion, "${terraform.env}.name", var.bastion["default.name"])}"
  description = "${lookup(var.bastion, "${terraform.env}.name", var.bastion["default.name"])} Security Group by Terraform"
  vpc_id      = "${lookup(var.vpc, "vpc_id")}"

  tags {
    Name = "${lookup(var.bastion, "${terraform.env}.name", var.bastion["default.name"])}"
  }

  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]

    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group_rule" "ssh_from_all_to_bastion" {
  from_port         = "22"
  protocol          = "tcp"
  security_group_id = "${aws_security_group.bastion.id}"
  to_port           = "22"
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]

  ipv6_cidr_blocks = ["::/0"]
}

resource "aws_key_pair" "ssh_key_pair" {
  public_key = "${file(var.ssh_public_key_path)}"
  key_name   = "${terraform.workspace}-ssh-key"
}

resource "aws_instance" "bastion_1" {
  ami                         = "${lookup(var.bastion, "${terraform.env}.ami", var.bastion["default.ami"])}"
  associate_public_ip_address = true
  instance_type               = "${lookup(var.bastion, "${terraform.env}.instance_type", var.bastion["default.instance_type"])}"

  ebs_block_device {
    device_name = "/dev/xvda"
    volume_type = "${lookup(var.bastion, "${terraform.env}.volume_type", var.bastion["default.volume_type"])}"
    volume_size = "${lookup(var.bastion, "${terraform.env}.volume_size", var.bastion["default.volume_size"])}"
  }

  key_name               = "${aws_key_pair.ssh_key_pair.id}"
  subnet_id              = "${var.vpc["subnet_public_1"]}"
  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]

  tags {
    Name = "${lookup(var.bastion, "${terraform.env}.name", var.bastion["default.name"])}-1"
  }

  lifecycle {
    ignore_changes = [
      "*",
    ]
  }
}

resource "aws_eip" "bastion_1" {
  instance = "${aws_instance.bastion_1.id}"

  tags {
    Name = "${lookup(var.bastion, "${terraform.env}.name", var.bastion["default.name"])}-1"
  }
}

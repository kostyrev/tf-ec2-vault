terraform {
  required_version = ">= 0.10.6"
}

provider "aws" {
  region = "${var.region}"
}

data "aws_availability_zone" "example" {
  name = "${format("%sa", var.region)}"
}

data "aws_vpc" "vpc" {
  tags {
    Name = "${format("%s", var.vpc_name)}"
  }
}

data "aws_subnet" "subnet" {
  vpc_id            = "${data.aws_vpc.vpc.id}"
  availability_zone = "${data.aws_availability_zone.example.name}"
}

data "aws_ami" "consul" {
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["consul-0.9.2"]
  }

  owners = ["762089471837"]
}

module "consul" {
  name             = "${format("%s-test", var.env)}"
  source           = "git::https://github.com/kostyrev/tf-ec2-consul-elb"
  vpc_id           = "${data.aws_vpc.vpc.id}"
  subnet_ids       = ["${data.aws_subnet.subnet.id}"]
  image_id         = "${data.aws_ami.consul.image_id}"
  instance_type    = "t2.micro"
  min_size         = 1
  max_size         = 1
  bootstrap_expect = 1
  datacenter       = "${var.region}"
  ec2_tag_value    = "${format("%s-consul", var.env)}"
  ebs_optimized    = false
}

data "aws_ami" "vault" {
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "name"
    values = ["vault-0.8.3"]
  }

  owners = ["762089471837"]
}

module "vault" {
  # source           = "git::https://github.com/kostyrev/tf-ec2-vault.git"
  source           = "../"
  name             = "${format("%s-vault", var.env)}"
  ami              = "${data.aws_ami.vault.image_id}"
  subnets          = ["${data.aws_subnet.subnet.id}"]
  instance_type    = "t2.micro"
  instance_profile = "${module.consul.profile}"
  vpc_id           = "${data.aws_vpc.vpc.id}"
  nodes            = 1
  datacenter       = "${var.region}"
  ec2_tag_value    = "${format("%s-consul", var.env)}"
  elb_health_check = "HTTPS:8200/v1/sys/health"
}

resource "aws_security_group_rule" "vault-consul-rpc" {
  security_group_id        = "${module.consul.consul_security_group}"
  type                     = "ingress"
  from_port                = 8300
  to_port                  = 8300
  protocol                 = "tcp"
  source_security_group_id = "${module.vault.vault_security_group}"
}

resource "aws_security_group_rule" "vault-consul-serf-tcp" {
  security_group_id        = "${module.consul.consul_security_group}"
  type                     = "ingress"
  from_port                = 8301
  to_port                  = 8301
  protocol                 = "tcp"
  source_security_group_id = "${module.vault.vault_security_group}"
}

resource "aws_security_group_rule" "vault-consul-serf-udp" {
  security_group_id        = "${module.consul.consul_security_group}"
  type                     = "ingress"
  from_port                = 8301
  to_port                  = 8301
  protocol                 = "udp"
  source_security_group_id = "${module.vault.vault_security_group}"
}

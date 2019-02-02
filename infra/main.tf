provider "aws" {
  region = "${var.region}"
}

resource "aws_key_pair" "access" {
  key_name   = "${var.key_name}"
  public_key = "${file(pathexpand(var.public_key_path))}"
}

data "aws_ami" "bionic" {
  most_recent = "true"

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow-ssh"
  description = "Allow SSH ingress."

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }
}

resource "aws_security_group" "egress_all" {
  name        = "egress-all"
  description = "Allow all egress traffic."

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }
}

data "template_file" "init" {
  count    = "${length(var.targets)}"
  template = "${file("init.sh")}"

  vars {
    target             = "${var.targets[count.index]}"
    go_version         = "${var.go_version}"
    deploy_private_key = "${file(var.deploy_private_key_path)}"
  }
}

resource "aws_instance" "worker" {
  count           = "${length(var.targets)}"
  ami             = "${data.aws_ami.bionic.image_id}"
  instance_type   = "${var.instance_type}"
  key_name        = "${aws_key_pair.access.key_name}"
  security_groups = ["${aws_security_group.allow_ssh.name}", "${aws_security_group.egress_all.name}"]
  user_data       = "${element(data.template_file.init.*.rendered, count.index)}"

  tags = {
    Name = "${var.targets[count.index]}"
  }
}

locals {
  deploy_dir = "/opt/${var.project_name}"
}

provider "aws" {
  region = "${var.region}"
}

resource "aws_s3_bucket" "storage" {
  bucket = "${var.project_name}"
  acl    = "private"
}

resource "aws_s3_bucket_object" "package" {
  bucket = "${aws_s3_bucket.storage.id}"
  key    = "package/${basename(var.package_path)}"
  source = "${var.package_path}"
  etag   = "${md5(file(var.package_path))}"
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

resource "aws_iam_role" "prod_role" {
  name = "${var.project_name}-prod-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "prod_role_policy" {
  name = "${var.project_name}-prod-role-policy"
  role = "${aws_iam_role.prod_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::${aws_s3_bucket.storage.id}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListObjects"
      ],
      "Resource": ["arn:aws:s3:::${aws_s3_bucket.storage.id}/*"]
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "prod_profile" {
  name = "${var.project_name}-prod-profile"
  role = "${aws_iam_role.prod_role.name}"
}

data "template_file" "init" {
  count    = "${length(var.targets)}"
  template = "${file("init.sh")}"

  vars {
    target                = "${var.targets[count.index]}"
    deploy_dir            = "${local.deploy_dir}"
    deploy_package_s3_uri = "s3://${aws_s3_bucket.storage.id}/${aws_s3_bucket_object.package.id}"
    target_dir            = "${local.deploy_dir}/target/${var.targets[count.index]}"
  }
}

resource "aws_instance" "worker" {
  count                = "${length(var.targets)}"
  ami                  = "${data.aws_ami.bionic.image_id}"
  instance_type        = "${var.instance_type}"
  key_name             = "${aws_key_pair.access.key_name}"
  security_groups      = ["${aws_security_group.allow_ssh.name}", "${aws_security_group.egress_all.name}"]
  user_data            = "${element(data.template_file.init.*.rendered, count.index)}"
  iam_instance_profile = "${aws_iam_instance_profile.prod_profile.id}"

  tags = {
    Name = "${var.targets[count.index]}"
  }
}

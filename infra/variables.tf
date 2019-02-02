variable "deploy_private_key_path" {}

variable "targets" {
  type = "list"

  default = [
    "aesgcm",
    "chacha20poly1305",
    "sha1",
    "sha256",
    "sha512",
  ]
}

variable "go_version" {
  default = "1.11.5"
}

variable "region" {
  default = "us-west-2"
}

variable "key_name" {
  default = "cryptofuzz"
}

variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "instance_type" {
  default = "t2.micro"
}

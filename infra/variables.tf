variable "package_path" {}

variable "project_name" {
  default = "cryptofuzz"
}

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

variable "region" {
  default = "us-west-2"
}

variable "key_name" {
  default = "personal"
}

variable "public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "coordinator_instance_type" {
  default = "t2.micro"
}

variable "workers_target_ecu" {
  default = 64
}

variable "coordinator_port" {
  default = 8745
}

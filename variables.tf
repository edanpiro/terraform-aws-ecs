variable "subnet_public_cidr" {
  type = "list"
}

variable "subnet_public_zone" {
  type = "list"
}

variable "ssh-public-key" {
  type = "string"
  default = "~/.ssh/id_rsa.pub"
}

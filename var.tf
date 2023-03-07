variable "aws_region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnets_cidr" {
  type    = list(string)
  default = ["10.0.1.0/24"]
}

variable "PRIVATE_IP" {
  default = ["10.0.1.12"]
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "amiid" {
  default = "ami-07dc2dd8e0efbc46a"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "number_instances" {
  default = "1"
}

variable "instance_uname" {
  default = "ubuntu"
}
variable "instance_pwd" {
  default = "ubuntu"
}

variable "path_to_privatekey" {
  default = "mykey"
}

variable "path_to_publickey" {
  default = "mykey.pub"
}

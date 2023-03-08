provider "aws" {
  region = var.aws_region
}

#VPC
resource "aws_vpc" "terra_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "Terraform_VPC"
  }
}

#Internet Gteway
resource "aws_internet_gateway" "terra_igw" {
  vpc_id = aws_vpc.terra_vpc.id
  tags = {
    Name = "main"
  }
}

#Subnets : public
resource "aws_subnet" "public" {
  count                   = length(var.subnets_cidr)
  vpc_id                  = aws_vpc.terra_vpc.id
  cidr_block              = element(var.subnets_cidr, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet-${count.index + 1}"
  }
}

#Route table: attach Internet Gateway
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.terra_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terra_igw.id
  }
  tags = {
    Name = "PublicRouteTable"
  }
}
#Route table association with public subnets
resource "aws_route_table_association" "a" {
  count          = length(var.subnets_cidr)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_security_group" "webservers" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.terra_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ssh from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "webservers" {
  count         = var.number_instances
  ami           = var.amiid
  instance_type = var.instance_type
  private_ip    = var.PRIVATE_IP[count.index]

  security_groups = ["${aws_security_group.webservers.id}"]
  subnet_id       = element(aws_subnet.public.*.id, count.index)
  key_name        = aws_key_pair.mykeypair.key_name
  tags = {
    Name = "Server-${count.index}"
  }

  provisioner "file" {
    source      = "/home/administrator/vahidha/test_PIPELINE/k8_package.zip"
    destination = "/tmp/k8_package.zip"
  }
  provisioner "file" {
    source      = "/home/administrator/Jenkins/workspace/test_PIPELINE_CD/install.sh"
    destination = "/tmp/install.sh"
  }
  provisioner "file" {
    source      = "/home/administrator/Jenkins/workspace/test_PIPELINE_CD/mykey"
    destination = "/tmp/mykey"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt install unzip",
      "cd /tmp",
      "unzip k8_package.zip",
      "chmod +x /tmp/install.sh",
      "/tmp/install.sh",
    ]
  }
  connection {
    host        = coalesce("", self.public_ip)
    type        = "ssh"
    user        = var.instance_uname
    private_key = file(var.path_to_privatekey)
  }
}

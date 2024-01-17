data "aws_vpc" "main" {
  id = "vpc_id"
}

data "aws_subnet" "public_subnet_1" {
  id = "public_subnet_id"
}

data "aws_subnet" "public_subnet_2" {
  id = "public_subnet_id"
}

data "aws_subnet" "private_subnet_1" {
  id = "private_subnet_id"
}

data "aws_subnet" "private_subnet_2" {
  id = "private_subnet_id"
}
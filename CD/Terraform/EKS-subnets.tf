resource "aws_vpc" "main" {
  cidr_block = var.cidr
}

resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = local.pub_subnet1
  map_public_ip_on_launch = true
  availability_zone = local.azs[0]

  tags = {
    Name = "public1"
    kubernetes.io/role/elb = 1
    
  }
}

resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = local.pub_subnet2
  map_public_ip_on_launch = true
  availability_zone = local.azs[1]

  tags = {
    Name = "public2"
    kubernetes.io/role/elb = 1
  }
}

resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = local.pri_subnet1
  map_public_ip_on_launch = false
  availability_zone = local.azs[0]


  tags = {
    Name = "private1"
    kubernetes.io/role/internal-elb = 1
  }
}

resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = local.pri_subnet2
  map_public_ip_on_launch = false
  availability_zone = local.azs[1]

  tags = {
    Name = "private2"
    kubernetes.io/role/internal-elb = 1
  }
}

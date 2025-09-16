resource "aws_vpc" "main" {
  cidr_block = var.cidr
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = local.pub_subnet1
  map_public_ip_on_launch = true
  availability_zone = local.azs[0]

  tags = {
    Name = "public"
  }
}

resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = local.pub_subnet2
  map_public_ip_on_launch = true
  availability_zone = local.azs[1]

  tags = {
    Name = "public"
  }
}

# resource "aws_subnet" "private" {
#   vpc_id     = aws_vpc.main.id
#   cidr_block = local.pri_subnet
#   availability_zone = local.azs[1]

#   tags = {
#     Name = "private"
#   }
# }
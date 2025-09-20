resource "aws_eip" "eip" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "NAT" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public1.id

  tags = {
    Name = "gw NAT"
  }


  depends_on = [aws_eip.eip]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "publicRT" {
  vpc_id = aws_vpc.main.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
    
  }

  tags = {
    Name = "publicRT"
  }
}

resource "aws_route_table_association" "publicRT1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.publicRT.id
}
resource "aws_route_table_association" "publicRT2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.publicRT.id
}




resource "aws_route_table" "PrivateRT" {
  vpc_id = aws_vpc.main.id


  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT.id
    
  }

  tags = {
    Name = "PrivateRT"
  }
}



resource "aws_route_table_association" "PrivateRT1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.PrivateRT.id
}
resource "aws_route_table_association" "PrivateRT2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.PrivateRT.id
}

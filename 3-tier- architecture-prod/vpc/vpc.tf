
# Creating VPC
resource "aws_vpc" "demovpc" { # vpc name 
  cidr_block = var.vpc_cidr
  #instance_tenancy = "default"
  tags = {
    Name = "Demo VPC"
  }
}






# Creating 1st web subnet 
resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = aws_vpc.demovpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"
  tags = {
    Name = "Web Subnet 1"
  }
}
# Creating 2nd web subnet 
resource "aws_subnet" "public-subnet-2" {
  vpc_id                  = aws_vpc.demovpc.id
  cidr_block              = var.subnet1_cidr
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1b"
  tags = {
    Name = "Web Subnet 2"
  }
}
# Creating 1st application subnet 
resource "aws_subnet" "application-subnet-1" {
  vpc_id                  = aws_vpc.demovpc.id
  cidr_block              = var.subnet2_cidr
  map_public_ip_on_launch = false
  availability_zone       = "ap-south-1a"
  tags = {
    Name = "Application Subnet 1"
  }
}
# Creating 2nd application subnet 
resource "aws_subnet" "application-subnet-2" {
  vpc_id                  = aws_vpc.demovpc.id
  cidr_block              = var.subnet3_cidr
  map_public_ip_on_launch = false
  availability_zone       = "ap-south-1b"
  tags = {
    Name = "Application Subnet 2"
  }
}
# Create Database Private Subnet
resource "aws_subnet" "database-subnet-1" {
  vpc_id            = aws_vpc.demovpc.id
  cidr_block        = var.subnet4_cidr
  availability_zone = "ap-south-1a"
  tags = {
    Name = "Database Subnet1 "
  }
}
# Create Database Private Subnet
resource "aws_subnet" "database-subnet-2" {
  vpc_id            = aws_vpc.demovpc.id
  cidr_block        = var.subnet5_cidr
  availability_zone = "ap-south-1b"
  tags = {
    Name = "Database Subnet2 "
  }
}



# Creating Internet Gateway 
resource "aws_internet_gateway" "demogateway" {
  vpc_id = aws_vpc.demovpc.id
}




# Creating Route Table
resource "aws_route_table" "route" {
  vpc_id = aws_vpc.demovpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demogateway.id
  }
  tags = {
    Name = "Route to internet"
  }
}

resource "aws_route_table_association" "public_route_table_association_1" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.route.id
}
resource "aws_route_table_association" "public_route_table_association_2" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.route.id
}




resource "aws_route_table" "database_route_table" {
  vpc_id = aws_vpc.demovpc.id

  tags = {
    Name = "database-route-table"
  }
}

resource "aws_route_table_association" "database_route_table_association_1" {
  subnet_id      = aws_subnet.database-subnet-1.id
  route_table_id = aws_route_table.database_route_table.id
}
resource "aws_route_table_association" "database_route_table_association_2" {
  subnet_id      = aws_subnet.database-subnet-2.id
  route_table_id = aws_route_table.database_route_table.id
}



resource "aws_route_table" "application_route_table" {
  vpc_id = aws_vpc.demovpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gateway.id
  }


  tags = {
    Name = "application-route-table"
  }
}


resource "aws_route_table_association" "application_route_table_association_1" {
  subnet_id      = aws_subnet.application-subnet-1.id
  route_table_id = aws_route_table.application_route_table.id
}
resource "aws_route_table_association" "application_route_table_association_2" {
  subnet_id      = aws_subnet.application-subnet-2.id
  route_table_id = aws_route_table.application_route_table.id
}



resource "aws_eip" "ip" {
  vpc = true
  tags = {
    Name = "t4-elasticIP"
  }
}

resource "aws_nat_gateway" "nat-gateway" {
  allocation_id = aws_eip.ip.id
  subnet_id     = aws_subnet.public-subnet-1.id


  tags = {
    Name = "nat-gateway"
  }
}

/*
provider "tls" {}
resource "tls_private_key" "t" {
    algorithm = "RSA"
}
resource "aws_key_pair" "test" {
    key_name   = "task4-key"
    public_key = "${tls_private_key.t.public_key_openssh}"
}
provider "local" {}
resource "local_file" "key" {
    content  = "${tls_private_key.t.private_key_pem}"
    filename = "task4-key.pem"
       
}


/*













/*

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.myIGW.id
}



*/








/*
# Associating Route Table
resource "aws_route_table_association" "rt1" {
    subnet_id = "${aws_subnet.public-subnet-1.id}"
    route_table_id = "${aws_route_table.route.id}"
}

resource "aws_route_table_association" "rt1" {
    subnet_id = "${aws_subnet.public-subnet-1.id}"
    route_table_id = "${aws_route_table.route.id}"
}

*/

/*
# Associating Route Table
resource "aws_route_table_association" "rt2" {
    subnet_id = "${aws_subnet.demosubnet1.id}"
    route_table_id = "${aws_route_table.route.id}"
}

*/
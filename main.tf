# To point provider to AWS, also region is set to N.Virginia
provider "aws" {
    region = "us-east-1"
}

# Create a main VPC
resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "main-vpc"
    }
}

# subnet A and B are created in the main VPC
resource "aws_subnet" "A" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = "10.0.1.0/24"
    availability_zone = "us-east-1a"

    tags = {
        Name = "subnet A"
    }
}
resource "aws_subnet" "B" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = "10.0.2.0/24"
    availability_zone = "us-east-1b"

    tags = {
        Name = "subnet B"
    }
}

# Create an internet gateway
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "main-igw"
    }
}

# Create a route table for subnet A
resource "aws_route_table" "A" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }

    tags = {
        Name = "route-table-A"
    }
}

# Associate the route table with subnet A
resource "aws_route_table_association" "A" {
    subnet_id      = aws_subnet.A.id
    route_table_id = aws_route_table.A.id
}
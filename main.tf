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
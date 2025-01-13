provider "aws" {
    region = "us-east-1"
}

# Create a new key pair
resource "aws_key_pair" "B_key" {
    key_name   = "subnetB-key"
    public_key = file("~/.ssh/id_rsa.pub")
}

# Create an EC2 instance in subnet B
resource "aws_instance" "subnetB_instance" {
    ami           = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    key_name      = aws_key_pair.B_key.key_name
    subnet_id     = "subnet-0eb268a62cd02cbb8" # subnet B id put here

    tags = {
        Name = "SubnetBInstance"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo apt-get update",
            "sudo apt-get install -y docker.io",
            "sudo systemctl start docker",
            "sudo systemctl enable docker",
            "sudo docker run -d -p 80:80 --name nginx-container nginx",
            "sudo docker exec -it nginx-container bash -c 'echo \"<html><body><h1>Steven Chin</h1></body></html>\" > /usr/share/nginx/html/index.html'"
        ]
    }

    connection {
        type        = "ssh"
        user        = "ubuntu"
        private_key = file("~/.ssh/id_rsa")
        host        = self.public_ip
    }
}

data "aws_ami" "ubuntu" {
    most_recent = true
    owners      = ["099720109477"]  # Canonical

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }
}

resource "aws_ami_from_instance" "my_new_ami" {
    name               = "my-new-ami-${timestamp()}"
    source_instance_id = aws_instance.subnetB_instance.id
    description        = "An AMI created from instance ${aws_instance.subnetB_instance.id}"
    tags = {
        Name = "SubnetB_AMI"
    }
}

output "ami_id" {
    value = aws_ami_from_instance.my_new_ami.id
}
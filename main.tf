provider "aws" {
    region = "ap-south-1"
}

resource "aws_vpc" "library4_vpc" {
    cidr_block = "10.0.0.0/16"
    tags       = { Name = "library4-vpc"}
}

resource "aws_subnet" "public_subnet" {
    vpc_id                  = aws_vpc.library4_vpc.id
    cidr_block              = "10.0.0.0/21"
    map_public_ip_on_launch = true
    availability_zone        = "ap-south-1a"
    tags                    = { Name = "library4-subnet"}
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.library4_vpc.id
}

resource "aws_route_table" "public_rt" {
    vpc_id     = aws_vpc.library4_vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

resource "aws_route_table_association" "library4_association" {
    subnet_id      = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "library4_sg" {
    vpc_id = aws_vpc.library4_vpc.id

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"] 
    }
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port   = 30080
        to_port     = 30080
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

resource "aws_key_pair" "library4_key" {
    key_name   = "library4-key"
    public_key = file("f:/file/devops/library4/library4-key.pub")
}

resource "aws_instance" "library4_server" {
    ami                    = "ami-05d2d839d4f73aafb"
    instance_type          = "m7i-flex.large"
    subnet_id              = aws_subnet.public_subnet.id
    vpc_security_group_ids = [aws_security_group.library4_sg.id]
    key_name               = aws_key_pair.library4_key.key_name

    root_block_device {
        volume_size = 16
        volume_type = "gp3"
    }
    tags = { Name = "library4-server" }
}

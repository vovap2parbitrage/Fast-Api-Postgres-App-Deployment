resource "aws_vpc" "main_vpc" {
    cidr_block = var.vpc_cidr
    
    tags = {
        Name = "main-vpc"
    }
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.main_vpc.id
    cidr_block = var.public_subnet_cidr
    map_public_ip_on_launch = true
    
    tags = {
        Name = "public-subnet"
    }
}

resource "aws_internet_gateway" "main_igw" {
    vpc_id = aws_vpc.main_vpc.id

    tags = {
        Name = "main-igw"
    }
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.main_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main_igw.id
    }

    tags = {
        Name = "public-rt"
    }
}

resource "aws_route_table_association" "public_assoc" {
    subnet_id = aws_subnet.public_subnet.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "public_sg" {
    name = "public-sg"
    description = "Public SG configuration"
    vpc_id = aws_vpc.main_vpc.id
    
    tags = {
        Name = "public-sg"
    }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
    security_group_id = aws_security_group.public_sg.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 22
    to_port = 22
    ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
    security_group_id = aws_security_group.public_sg.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 80
    to_port = 80
    ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outgoing_taffic" {
    security_group_id = aws_security_group.public_sg.id
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "-1"
}

data "aws_ami" "ubuntu" {
    most_recent = true
    owners = ["099720109477"]

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-*"]
    }
}

resource "aws_key_pair" "def_key" {
    key_name = "def-key"

    public_key = file("~/.ssh/def-key.pub")
}

resource "aws_instance" "public_instance" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.instance_type
    subnet_id = aws_subnet.public_subnet.id
    vpc_security_group_ids = [aws_security_group.public_sg.id]
    key_name = aws_key_pair.def_key.key_name
    associate_public_ip_address = true

    user_data = file("${path.module}/scripts/userdata.sh")
}
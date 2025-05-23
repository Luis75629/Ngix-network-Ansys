provider "aws" {
  region = var.region
}


resource "aws_vpc" "ansys" {
  cidr_block = var.ip_vpc

  tags = {
    Name = "${local.project}"
  }
}

resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.ansys.id
  cidr_block = var.subnet_ip[0]

  tags = {
    Name = "public-subnet1-${local.project}"
  }
}

resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.ansys.id
  cidr_block = var.subnet_ip[1]

  tags = {
    Name = "public-subnet2-${local.project}"
  }
}

resource "aws_subnet" "public3" {
  vpc_id     = aws_vpc.ansys.id
  cidr_block = var.subnet_ip[2]

  tags = {
    Name = "public-subnet3-${local.project}"
  }
}

resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.ansys.id
  cidr_block = var.subnet_ip[3]

  tags = {
    Name = "private-subnet1-${local.project}"
  }
}

resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.ansys.id
  cidr_block = var.subnet_ip[4]

  tags = {
    Name = "private-subnet2-${local.project}"
  }
}

resource "aws_subnet" "private3" {
  vpc_id     = aws_vpc.ansys.id
  cidr_block = var.subnet_ip[5]

  tags = {
    Name = "private-subnet3-${local.project}"
  }
}

resource "aws_internet_gateway" "igw_ansys" {
  vpc_id = aws_vpc.ansys.id

  tags = {
    Name = "igw-${local.project}"
  }
}

resource "aws_route_table" "ansys_table" {
  vpc_id = aws_vpc.ansys.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_ansys.id
  }

  tags = {
    Name = "rublic-route-table-${local.project}"
  }
}

resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.ansys_table.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.ansys_table.id
}

resource "aws_route_table_association" "public_assoc_3" {
  subnet_id      = aws_subnet.public3.id
  route_table_id = aws_route_table.ansys_table.id
}
resource "aws_security_group" "nginx_sg" {
  name        = "nginx-sg-${local.project}"
  description = "Allow inbound HTTP traffic"
  vpc_id      = aws_vpc.ansys.id
  tags = {
    Name = "sg-public-route-${local.project}"
  }

  ingress {
    description = "HTTP access from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS access from the internet"
    from_port   = 443
    to_port     = 443
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

resource "aws_instance" "nginx_1" {
  ami                    = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public1.id
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  user_data              = file("./scripts/install-ngix.sh")
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name

  tags = {
    Name = "nginx-server1-${local.project}"
  }
}

resource "aws_instance" "nginx_2" {
  ami                    = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public2.id
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  user_data              = file("./scripts/install-ngix.sh")
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name

  tags = {
    Name = "nginx-server2-${local.project}"
  }
}

resource "aws_instance" "nginx_3" {
  ami                    = "resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public3.id
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  user_data              = file("./scripts/install-ngix.sh")
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name

  tags = {
    Name = "nginx-server3-${local.project}"
  }
}

resource "aws_iam_role" "ssm_instance_role" {
  name               = "ec2_ssm"
  assume_role_policy = file("./policies/ec2.json")

}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm_instance_profile"
  role = aws_iam_role.ssm_instance_role.name
}

resource "aws_eip" "nginx_eip_1" {
  instance = aws_instance.nginx_1.id
  domain   = "vpc"
}

resource "aws_eip" "nginx_eip_2" {
  instance = aws_instance.nginx_2.id
  domain   = "vpc"
}

resource "aws_eip" "nginx_eip_3" {
  instance = aws_instance.nginx_3.id
  domain   = "vpc"
}

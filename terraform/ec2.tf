# Fetch Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Web Server 1
resource "aws_instance" "web_server_1" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]
  key_name               = var.key_pair_name

  user_data = templatefile("user_data.sh", {
    rds_endpoint = aws_db_instance.rds.endpoint,
    db_username  = var.db_username,
    db_password  = var.db_password,
    public_ip    = aws_instance.web_server_1.public_ip
  })

  tags = {
    Name = "web-server-1"
  }
}

# Web Server 2
resource "aws_instance" "web_server_2" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_b.id
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]
  key_name               = var.key_pair_name

  user_data = templatefile("user_data.sh", {
    rds_endpoint = aws_db_instance.rds.endpoint,
    db_username  = var.db_username,
    db_password  = var.db_password,
    public_ip    = aws_instance.web_server_2.public_ip
  })

  tags = {
    Name = "web-server-2"
  }
}

# Bastion Host
resource "aws_instance" "bastion_host" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]
  key_name               = var.key_pair_name

  tags = {
    Name = "bastion-host"
  }
}

# Fetches the latest Amazon Linux 2023 AMI ID from AWS Systems Manager Parameter Store
data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "web_server_1" {
  ami                    = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]
  key_name               = var.key_pair_name
  user_data              = templatefile("user_data.sh", {
    rds_endpoint = aws_db_instance.rds.endpoint,
    db_username  = var.db_username,
    db_password  = var.db_password,
    public_ip    = "web_server_1.public_ip"
  })
  tags = {
    Name = "web-server-1"
  }
}

resource "aws_instance" "web_server_2" {
  ami                    = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_b.id
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]
  key_name               = var.key_pair_name
  user_data              = templatefile("user_data.sh", {
    rds_endpoint = aws_db_instance.rds.endpoint,
    db_username  = var.db_username,
    db_password  = var.db_password,
    public_ip    = "web_server_2.public_ip"
  })
  tags = {
    Name = "web-server-2"
  }
}

resource "aws_instance" "bastion_host" {
  ami                    = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]
  key_name               = var.key_pair_name
  tags = {
    Name = "bastion-host"
  }
}
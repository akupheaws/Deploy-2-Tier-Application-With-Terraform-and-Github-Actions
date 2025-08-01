resource "aws_db_instance" "main" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "SmartTodoWebAppDB"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.database_sg.id]
  skip_final_snapshot    = true
  storage_type           = "gp2"
  publicly_accessible    = false
  tags = {
    Name = "SmartTodoWebApp-Instance"
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "smarttodowebapp-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = {
    Name = "SmartTodoWebApp-Subnet-Group"
  }
}

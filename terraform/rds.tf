resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "smarttodowebapp-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
  tags = {
    Name = "SmartTodoWebApp-Subnet-Group"
  }
}

resource "aws_db_instance" "rds" {
  identifier              = "smarttodowebapp-instance"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  username               = var.db_username
  password               = var.db_password
  db_name                = "SmartTodoWebAppDB"
  vpc_security_group_ids = [aws_security_group.database_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = false
  tags = {
    Name = "SmartTodoWebApp-Instance"
  }
}
# Creating RDS Instance

resource "aws_db_subnet_group" "rds_subnet_grp" {
  #this subnet group for rds
  name = "subnet-group"

  subnet_ids = [aws_subnet.database-subnet-1.id, aws_subnet.database-subnet-2.id]

  # rds subnet group name
  tags = {
    Name = " DB subnet group"
  }
}
# this is RDS for mysql
resource "aws_db_instance" "mysql" {
  # local name  
  identifier = "development"
  # storage type
  allocated_storage = 10
  #vpc_id                  = "${aws_vpc.demovpc.id}"
  #db group attached to rds
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_grp.id
  # engine name   
  engine = var.engine_name
  # db name           
  name = var.db_name
  # mysql engine version
  engine_version = "10.6.10"
  # storage type   
  storage_type   = "gp2"
  port           = 3306
  instance_class = var.instance_class # instance class type for rds
  # multi_az                 = var.multi_az_deployment     
  publicly_accessible = var.public_access
  # mysql username
  username = var.user_name
  # mysql username
  password                 = var.pass
  delete_automated_backups = var.delete_automated_backup
  skip_final_snapshot      = var.skip_finalSnapshot
  # sg for database (3306 allow in sg group)
  #vpc_security_group_ids = [aws_security_group.database-sg.id]      
  vpc_security_group_ids = ["${aws_security_group.demosg.id}"]

}


# Creating the autoscaling launch configuration that contains AWS EC2 instance details


resource "aws_launch_configuration" "web" {
  name = "lauch-config" #"test-lc"

  image_id = "ami-01216e7612243e0ef"

  instance_type = "t2.micro"

  key_name                    = "mumbai-key"
  security_groups             = ["${aws_security_group.demosg.id}"]
  associate_public_ip_address = true
  #user_data = file("${path.module}/user-data.sh")

  user_data = <<-EOF

            #!/bin/bash -xe

# Setpassword & DB Variables
DBName='db'
DBUser='admin'
DBPassword='admin.123'
DBRootPassword='admin.123'
DBEndpoint= '${aws_db_instance.mysql.endpoint}'

# System Updates
yum -y update
yum -y upgrade

# STEP 2 - Install system software - including Web and DB
yum install -y mariadb-server httpd
amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2

# STEP 3 - Web and DB Servers Online - and set to startup
systemctl enable httpd
systemctl enable mariadb
systemctl start httpd
systemctl start mariadb

# STEP 4 - Set Mariadb Root Password
mysqladmin -u root password $DBRootPassword

# STEP 5 - Install Wordpress
wget http://wordpress.org/latest.tar.gz -P /var/www/html
cd /var/www/html
tar -zxvf latest.tar.gz
cp -rvf wordpress/* .
rm -R wordpress
rm latest.tar.gz

# STEP 6 - Configure Wordpress
cp ./wp-config-sample.php ./wp-config.php
sed -i "s/'database_name_here'/'$DBName'/g" wp-config.php
sed -i "s/'username_here'/'$DBUser'/g" wp-config.php
sed -i "s/'password_here'/'$DBPassword'/g" wp-config.php
sed -i "s/'localhost'/'$DBEndpoint'/g" wp-config.php
# Step 6a - permissions 
usermod -a -G apache ec2-user   
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;

# STEP 7 Create Wordpress DB
echo "CREATE DATABASE $DBName;" >> /tmp/db.setup
echo "CREATE USER '$DBUser'@'localhost' IDENTIFIED BY '$DBPassword';" >> /tmp/db.setup
echo "GRANT ALL ON $DBName.* TO '$DBUser'@'localhost';" >> /tmp/db.setup
echo "FLUSH PRIVILEGES;" >> /tmp/db.setup
mysql -u root --password=$DBRootPassword < /tmp/db.setup
sudo rm /tmp/db.setup


            EOF


  /*
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
*/

}



resource "aws_autoscaling_group" "web" {
  name = "${aws_launch_configuration.web.name}-asg"
  depends_on = [
    aws_elb.web_elb
  ]

  vpc_zone_identifier = [
    "${aws_subnet.application-subnet-1.id}",
    "${aws_subnet.application-subnet-2.id}"
  ]


  min_size         = 2
  desired_capacity = 2
  max_size         = 2

  health_check_type = "ELB"
  load_balancers = [
    "${aws_elb.web_elb.id}"
  ]
  launch_configuration = aws_launch_configuration.web.name


  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]
  metrics_granularity = "1Minute"
  /*
vpc_zone_identifier  = [
    "${aws_subnet. application-subnet-1.id}",
    "${aws_subnet. application-subnet-2.id}"
  ]
*/

  tag {
    key                 = "Name"
    value               = "web"
    propagate_at_launch = true
  }
}









resource "aws_alb_target_group" "group" {
  name        = "terraform--alb-target"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.demovpc.id
  #stickiness {
  # type = "lb_cookie"
  #}
  # Alter the destination of the health check to be the login page.
  health_check {
    path = "/login"
    port = 80
  }
}






resource "aws_elb" "web_elb" {

  name = "web-elb"
 #load_balancer_type = "network"
  internal           = false
 

  depends_on = [
    aws_db_instance.mysql
  ]


  security_groups = [
    "${aws_security_group.demosg.id}"
  ]
  subnets = [
    "${aws_subnet.public-subnet-1.id}",
    "${aws_subnet.public-subnet-2.id}"
  ]

  cross_zone_load_balancing = true

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:80/"
  }
  
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "80"
    instance_protocol = "http"
  }


}


resource "aws_autoscaling_attachment" "asg_attachment_elb" {
  autoscaling_group_name = aws_autoscaling_group.web.id
  #elb                    = aws_elb.web_elb.id
  alb_target_group_arn = aws_alb_target_group.group.arn

}











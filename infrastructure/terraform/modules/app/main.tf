# ALB 
resource "aws_lb" "this" {
  name               = "${var.project}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "${var.project}-alb"
  }
}

# ALB HTTP Listener
resource "aws_lb_listener" "http" {
    load_balancer_arn = aws_lb.this.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
      type  = "redirect"
      redirect {
        port          = "443"
        protocol      = "HTTPS"
        status_code   = "HTTP_301"
      }
    }
}

# ALB HTTPS Listener
resource "aws_lb_listener" "https" {
    load_balancer_arn = aws_lb.this.arn
    port              = "443"
    protocol          = "HTTPS"
    ssl_policy        = "ELBSecurityPolicy-2016-08"
    certificate_arn   = var.certificate_arn

    default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.app.arn 
    }
}

# Target Group
resource "aws_lb_target_group" "app" {
  name        = "${var.project}-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path                = "/health"
    port                = "5000"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name = "${var.project}-tg"
  }
}

# EC2 Instance
resource "aws_instance" "app" {
  count         = length(var.private_subnet_ids)
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"
  subnet_id     = element(var.private_subnet_ids, count.index)
  security_groups = [aws_security_group.ec2.id]

  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  tags = {
    Name = "${var.project}-app-${count.index + 1}"
  }

user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y python3 git
              pip3 install flask psycopg2-binary python-dotenv

              cd /home/ec2-user
              git clone https://github.com/Zach-Maestas/secure-aws-architecture-capstone.git app || \
              (cd app && git pull)

              # Create systemd service for Flask
              sudo tee /etc/systemd/system/flask-app.service > /dev/null <<EOL
              [Unit]
              Description=Flask Application
              After=network.target

              [Service]
              User=ec2-user
              WorkingDirectory=/home/ec2-user/app/application
              ExecStart=/usr/bin/python3 app.py
              Restart=always
              Environment="DB_HOST=${DB_HOST}"
              Environment="DB_NAME=${DB_NAME}"
              Environment="DB_USER=${DB_USER}"
              Environment="DB_PASSWORD=${DB_PASSWORD}"

              [Install]
              WantedBy=multi-user.target
              EOL

              sudo systemctl daemon-reload
              sudo systemctl enable flask-app
              sudo systemctl start flask-app
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

# Register EC2 Instances with Target Group
resource "aws_lb_target_group_attachment" "app" {
  count            = length(aws_instance.app[*].id)
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.app[count.index].id
  port             = 5000
}

# IAM Role for SSM
resource "aws_iam_role" "ssm_role" {
  name = "${var.project}-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}


# Attach the AmazonSSMManagedInstanceCore policy
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM Instance Profile for EC2
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "${var.project}-ec2-ssm-profile"
  role = aws_iam_role.ssm_role.name
}

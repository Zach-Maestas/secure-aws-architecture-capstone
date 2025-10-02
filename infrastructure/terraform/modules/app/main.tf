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
    ssl_policy        = "ELBSecurityPolicy-2021-06"
    certificate_arn   = var.certificate_arn

    default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.app.arn 
    }
}

# Target Group
resource "aws_lb_target_group" "app" {
  name        = "${var.project}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"
  health_check {
    
    path                = "/"
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

  tags = {
    Name = "${var.project}-app-${count.index + 1}"
  }

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y nginx
              systemctl start nginx
              systemctl enable nginx
              echo "<h1>Welcome to ${var.project}!</h1>" > /var/www/html/index.html
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
  port             = 80
}

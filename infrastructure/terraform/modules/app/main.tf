# ALB 
resource "aws_lb" "this" {
  name               = "${var.project}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.security_group.alb_sg_id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "${var.project}-alb"
  }
}

# ALB Listener
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

resource "aws_lb_listener" "https" {
    load_balancer_arn = aws_lb.this.arn
    port              = "443"
    protocol          = "HTTPS"
    ssl_policy        = "ELBSecurityPolicy-2021-06"
    certificate_arn   = var.acm_certificate_arn

    default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.app.arn
    }
}

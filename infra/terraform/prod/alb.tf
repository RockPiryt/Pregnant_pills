
# Application Load Balancer (public-facing)
resource "aws_lb" "preg_alb" {
  name               = "preg-alb"
  load_balancer_type = "application"
  internal           = false

  subnets         = [aws_subnet.preg-public-subnet.id] # public subnet
  security_groups = [aws_security_group.alb_preg.id]

}

# Target Group pointing to EC2 instances (NodePort 30080)
resource "aws_lb_target_group" "preg_tg" {
  name        = "preg-tg"
  port        = 30080 
  protocol    = "HTTP"
  vpc_id      = aws_vpc.preg-vpc.id
  target_type = "instance" # Targets are EC2 instances

  # Health check configuration
  health_check {
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# HTTP listener
resource "aws_lb_listener" "preg_http" {
  load_balancer_arn = aws_lb.preg_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS listener
resource "aws_lb_listener" "preg_https" {
  load_balancer_arn = aws_lb.preg_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  certificate_arn = aws_acm_certificate.preg_aws_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.preg_tg.arn
  }
}

resource "aws_lb" "web_alb" {
  name               = "web-alb"
  load_balancer_type = "application"
  subnets            = []
}

output "alb_dns" {
  value = aws_lb.web_alb.dns_name
}

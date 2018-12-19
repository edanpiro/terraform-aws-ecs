resource "aws_security_group" "web_inbound" {
  name        = "pse-web_inbound"
  description = "Allow Http"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "web inbound"
  }
}

# API-DOCUMENT

resource "aws_alb_target_group" "lb_target_service" {
  name     = "service-lb-tg"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.default.id}"
  
  depends_on = [
    "aws_alb.load_balancer"
  ]
}

resource "aws_alb" "load_balancer" {
  name    = "pse-load-balancer"
  subnets = ["${aws_subnet.backend.*.id}"]
  security_groups = ["${aws_security_group.web_inbound.id}"]

  tags {
    Name = "pse"
  }
}

resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = "${aws_alb.load_balancer.arn}"
  port             = "80"
  protocol         = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.lb_target_service.arn}"
    type             = "forward"
  }

}

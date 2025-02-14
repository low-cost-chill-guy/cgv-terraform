resource "aws_lb_target_group" "chill_albtg" {
  count       = 2  # 대상 그룹을 2개 생성
  name        = "${var.tag}-target-group-${count.index}"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.eks_vpc.id
  target_type = "instance"

  tags = {
    Name = "${var.tag}-target-group-${count.index}"
  }

  
  health_check {
    enabled = true
    healthy_threshold = 3
    interval = 5
    matcher  = 200
    path     = "/index.html"
    port     = "traffic-port"
    protocol = "HTTP"
    timeout  = 2
    unhealthy_threshold = 3
  }

}

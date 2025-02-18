resource "aws_lb_listener" "chill_albli" {
  count             = 2  # ALB 리스너 2개 생성
  load_balancer_arn = aws_lb.chill_alb[count.index].arn  # ALB 인스턴스 참조
  port              = count.index == 0 ? 80 : 8088  # 첫 번째 리스너는 포트 80, 두 번째는 8080 사용
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.chill_albtg[count.index].arn  # 대상 그룹을 count.index로 참조
  }
}


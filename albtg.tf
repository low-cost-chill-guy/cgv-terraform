# 타겟 그룹 생성 (2개)
resource "aws_lb_target_group" "chill_albtg" {
  count       = 2
  name        = "${var.tag}-target-group-${count.index}"
  port        = count.index == 0 ? 80 : 8088
  protocol    = "HTTP"
  vpc_id      = aws_vpc.eks_vpc.id
  target_type = "instance"
  
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    timeout            = 5
    path               = "/"
    port               = count.index == 0 ? "80" : "8088"
  }

  tags = {
    Name = "${var.tag}-target-group-${count.index}"
  }
}

# Auto Scaling Group 연결
resource "aws_autoscaling_attachment" "asg_attachment" {
  count = 2
  autoscaling_group_name = aws_eks_node_group.eks_work_node.resources[0].autoscaling_groups[0].name
  lb_target_group_arn    = aws_lb_target_group.chill_albtg[count.index].arn

  depends_on = [
    aws_eks_node_group.eks_work_node,
    aws_lb_target_group.chill_albtg
  ]
}

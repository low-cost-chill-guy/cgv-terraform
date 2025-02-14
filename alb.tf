resource "aws_lb" "chill_alb" {
  count           = 2
  name            = "${var.tag}-alb"
  internal        = false
  security_groups = [aws_security_group.eks_secu.id]
  subnets         = [for subnet in aws_subnet.eksnet_bastion : subnet.id]  # 서브넷 ID들을 리스트로 전달
  tags = {
    Name = "${var.tag}-alb"
  }
}

output "alb_dnsname" {
  value = [for alb in aws_lb.chill_alb : alb.dns_name]
}


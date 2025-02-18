# AMI 데이터 소스
data "aws_ami" "eks_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${aws_eks_cluster.eks_clu.version}-v*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Launch Template 생성
resource "aws_launch_template" "eks_node_template" {
  name = "${var.tag}-node-template"
  image_id = data.aws_ami.eks_ami.id
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.eks_secu.id]

    block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30  # 디스크 크기 설정
      volume_type = "gp3"
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.tag}-node"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

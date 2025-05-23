# File: plume-gitlab-runner-project/runner_module/sg.tf

resource "aws_security_group" "gitlab_runner_sg" {
  name        = "${var.security_group_base_name}-sg"
  description = "Security group for GitLab Runner EC2 instances. Allows all outbound."
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound IPv4 traffic"
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1" # All protocols
    cidr_ipv6_blocks = ["::/0"]
    description      = "Allow all outbound IPv6 traffic"
  }

  tags = merge(var.common_module_tags, {
    "Name" = "${var.security_group_base_name}-sg"
  })
}
# File: gitlab-runner-deployment/runner_module/iam_resources/base_operational_role.tf

resource "aws_iam_role" "base_operational_role" {
  name = var.base_operational_role_name_input // From submodule variables
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { AWS = [aws_iam_role.gitlab_runner_ec2_instance_role.arn] }, // Trusts the EC2 role
      Action    = "sts:AssumeRole"
    }]
  })
  description = "Operational base role, assumed by GitLab Runner EC2's role."
  tags = merge(var.submodule_common_tags_input, {
    Name        = var.base_operational_role_name_input,
    Team        = "chtr-plido", Environment = "globaldev", Stack = "plume-tau", CreatedBy = "TerraformIAMSubmodule"
  })
}

resource "aws_iam_role_policy" "base_operational_role_json_policy" {
  name_prefix = "${var.base_operational_role_name_input}-baseJson-"
  role        = aws_iam_role.base_operational_role.id
  policy      = file("${path.module}/files/base-policy.json") // Correct path to base-policy.json
}
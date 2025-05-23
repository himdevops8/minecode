# File: gitlab-runner-deployment/runner_module/iam_resources/backup_restore_operational_role.tf

resource "aws_iam_role" "backup_restore_operational_role" {
  name = var.backup_restore_operational_role_name_input // Uses variable
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { AWS = [aws_iam_role.gitlab_runner_ec2_instance_role.arn] }, // Trusts the EC2 role
      Action    = "sts:AssumeRole"
    }]
  })
  description = "Operational backup/restore role, assumed by GitLab Runner EC2's role."
  tags = merge(var.submodule_common_tags_input, {
    Name        = var.backup_restore_operational_role_name_input,
    Team        = "chtr-plido", Environment = "globaldev", Stack = "plume-tau", CreatedBy = "TerraformIAMSubmodule"
  })
}

data "aws_iam_policy_document" "backup_restore_permissions_doc_for_submodule" { # Renamed
  statement {
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue"]
    resources = ["arn:aws:secretsmanager:us-east-1:750300312428:secret:use1-devops-tau-docdb-master-creds-riznhT"]
  }
  statement {
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["arn:aws:kms:us-east-1:750300312428:key/ad91afa2-f6a3-41d0-8c23-f2d93e27a8ab"]
  }
}
resource "aws_iam_role_policy" "backup_restore_operational_role_policy" {
  name_prefix = "${var.backup_restore_operational_role_name_input}-policy-"
  role        = aws_iam_role.backup_restore_operational_role.id
  policy      = data.aws_iam_policy_document.backup_restore_permissions_doc_for_submodule.json
}
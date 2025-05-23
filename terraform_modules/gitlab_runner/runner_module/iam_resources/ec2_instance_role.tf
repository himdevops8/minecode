# File: gitlab-runner-deployment/runner_module/iam_resources/ec2_instance_role.tf

data "aws_iam_policy_document" "ec2_instance_role_assume_policy_doc" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "gitlab_runner_ec2_instance_role" { # This is the role EC2 will run as
  name               = var.ec2_instance_role_name_input // From submodule variables
  assume_role_policy = data.aws_iam_policy_document.ec2_instance_role_assume_policy_doc.json
  description        = "IAM Role assumed by GitLab Runner EC2 instances."

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess",
    "arn:aws:iam::aws:policy/ResourceGroupsTaggingAPITagUntagSupportedResources",
  ]

  tags = merge(var.submodule_common_tags_input, {
    Name        = var.ec2_instance_role_name_input, // Use the exact name for the Name tag
    Team        = "chtr-plido",                     // From your original tags
    Environment = "globaldev",
    Stack       = "plume-tau",
    CreatedBy   = "TerraformIAMSubmodule"
  })
}

# This is the inline policy for the EC2 instance role itself (your old builder_policy)
resource "aws_iam_role_policy" "ec2_instance_role_sts_assume_targets_policy" {
  name_prefix = "${var.ec2_instance_role_name_input}-sts-assume-"
  role        = aws_iam_role.gitlab_runner_ec2_instance_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["sts:AssumeRole"]
        Resource = [ # These are the roles this EC2 instance role can assume
          aws_iam_role.base_operational_role.arn,           // Defined below in this submodule
          aws_iam_role.tf_deploy_operational_role.arn,      // Defined below in this submodule
          aws_iam_role.backup_restore_operational_role.arn, // Defined below in this submodule
          var.plume_tau_role_arn_for_ec2_to_assume_input  // Passed in from parent module
        ]
      },
      { # Added for Secrets Manager and core ECR/Logs for runner operation
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
          # ECR GetAuthorizationToken is covered by AmazonEC2ContainerRegistryFullAccess
        ]
        Resource = [
          var.gitlab_token_secret_arn_for_ec2_policy_input,
          "arn:aws:logs:*:*:*"
        ]
      }
    ]
  })
}
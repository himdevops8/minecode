# File: gitlab-runner-deployment/runner_module/iam_resources/tf_deploy_operational_role.tf

resource "aws_iam_role" "tf_deploy_operational_role" {
  name                  = var.tf_deploy_operational_role_name_input // From submodule variables
  description           = "Operational Tofu/Terraform deployment role, assumed by GitLab Runner EC2's role."
  force_detach_policies = true
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess", "arn:aws:iam::aws:policy/AmazonRoute53FullAccess",
    "arn:aws:iam::aws:policy/AmazonRDSFullAccess", "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
    "arn:aws:iam::aws:policy/AWSLambda_FullAccess", "arn:aws:iam::aws:policy/AmazonEventBridgeFullAccess",
    "arn:aws:iam::aws:policy/AmazonElastiCacheFullAccess", "arn:aws:iam::aws:policy/ResourceGroupsTaggingAPITagUntagSupportedResources",
  ]
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { AWS = [aws_iam_role.gitlab_runner_ec2_instance_role.arn] }, // Trusts the EC2 role
      Action    = "sts:AssumeRole"
    }]
  })
  tags = merge(var.submodule_common_tags_input, {
    Name        = var.tf_deploy_operational_role_name_input,
    Team        = "chtr-plido", Environment = "globaldev", Stack = "plume-tau", CreatedBy = "TerraformIAMSubmodule"
  })
}

# --- Inline Policies for tf_deploy_operational_role ---
# !!! ACTION REQUIRED: Define these policy documents based on your original tofu-role.tf !!!
# Replace all instances of local.account_id with var.aws_account_id

data "aws_iam_policy_document" "tf_deploy_eks_full_policy_doc" {
  # PASTE all statements from your original data "aws_iam_policy_document" "eks_full" here.
  # Example:
  statement { effect = "Allow", actions = ["eks:*"], resources = ["*"] }
  statement { effect = "Allow", actions = ["s3:*"], resources = ["*"] }
  # ... ensure all statements are copied and var.aws_account_id is used ...
}
resource "aws_iam_role_policy" "tf_deploy_eks_policy_attachment" {
  name_prefix = "${var.tf_deploy_operational_role_name_input}-eks-"
  role        = aws_iam_role.tf_deploy_operational_role.id
  policy      = data.aws_iam_policy_document.tf_deploy_eks_full_policy_doc.json
}

data "aws_iam_policy_document" "tf_deploy_iam_limited_policy_doc" {
  # PASTE all statements from your original data "aws_iam_policy_document" "iam_limited" here.
  # Ensure var.aws_account_id is used.
  # Example:
  statement { effect = "Allow", actions = ["iam:GetUser"], resources = ["arn:aws:iam::${var.aws_account_id}:user/*"] }
}
resource "aws_iam_role_policy" "tf_deploy_iam_limited_policy_attachment" {
  name_prefix = "${var.tf_deploy_operational_role_name_input}-iamlimited-"
  role        = aws_iam_role.tf_deploy_operational_role.id
  policy      = data.aws_iam_policy_document.tf_deploy_iam_limited_policy_doc.json
}

data "aws_iam_policy_document" "tf_deploy_wafv2_policy_doc" {
  # PASTE all statements from your original data "aws_iam_policy_document" "wafv2" here.
  # Ensure var.aws_account_id is used.
  statement { effect = "Allow", actions = ["wafv2:GetWebACL"], resources = ["arn:aws:wafv2:*:${var.aws_account_id}:regional/webacl/*/*"] }
}
resource "aws_iam_role_policy" "tf_deploy_wafv2_policy_attachment" {
  name_prefix = "${var.tf_deploy_operational_role_name_input}-wafv2-"
  role        = aws_iam_role.tf_deploy_operational_role.id
  policy      = data.aws_iam_policy_document.tf_deploy_wafv2_policy_doc.json
}

resource "aws_iam_role_policy" "tf_deploy_dynamodb_policy_attachment" {
  name_prefix = "${var.tf_deploy_operational_role_name_input}-dynamodb-"
  role        = aws_iam_role.tf_deploy_operational_role.id
  policy      = jsonencode({ # From your original tofu-role.tf
    Version   = "2012-10-17",
    Statement = [{ Effect = "Allow", Action = ["dynamodb:*"], Resource = "arn:aws:dynamodb:*:*:table/terraform-state-lock" }]
  })
}
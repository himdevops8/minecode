# File: plume-gitlab-runner-project/runner_module/iam.tf

data "aws_caller_identity" "current_for_module_iam_logic" {}

module "iam_roles_submodule" {
  source = "./iam_resources" # Path to the subdirectory containing all role definitions

  aws_account_id                             = data.aws_caller_identity.current_for_module_iam_logic.account_id
  aws_region_for_policies                    = var.aws_region
  ec2_instance_role_name_input               = var.iam_submodule_ec2_role_name
  base_operational_role_name_input           = var.iam_submodule_base_role_name
  tf_deploy_operational_role_name_input      = var.iam_submodule_tf_deploy_role_name
  backup_restore_operational_role_name_input = var.iam_submodule_backup_restore_role_name
  gitlab_token_secret_arn_for_ec2_policy_input = var.gitlab_registration_token_secret_arn // Ensure this var name matches module input
  plume_tau_role_arn_for_ec2_to_assume_input   = var.iam_submodule_plume_tau_role_arn_to_assume
  submodule_common_tags_input                  = var.iam_submodule_tags
}

resource "aws_iam_instance_profile" "runner_ec2_module_profile" {
  name_prefix = var.ec2_direct_instance_profile_name_prefix
  role        = module.iam_roles_submodule.created_ec2_instance_role_name # Output from iam_resources submodule

  tags = merge(var.common_module_tags, {
    Name = "${var.ec2_direct_instance_profile_name_prefix}-profile"
  })
}
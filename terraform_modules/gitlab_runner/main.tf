# File: gitlab-runner-deployment/main.tf
provider "aws" {
  region = var.aws_region
  default_tags { tags = var.root_provider_default_tags }
}

module "gitlab_runners_deployment" {
  source = "./runner_module"

  aws_region                     = var.aws_region
  vpc_id                         = var.vpc_id_for_runners
  runner_instance_configurations = var.runner_definitions
  gitlab_instance_url            = var.gitlab_base_url
  gitlab_registration_token_secret_arn = var.gitlab_token_secret_arn

  # Pass IAM configuration down to the runner_module
  iam_ec2_role_name_prefix                  = var.runner_module_iam_ec2_role_name_prefix_input
  ec2_direct_instance_profile_name_prefix = var.runner_module_iam_ec2_profile_prefix_input
  iam_operational_roles_name_suffix         = var.runner_module_iam_op_roles_suffix_input # For submodule
  iam_base_role_name_override               = var.runner_module_iam_op_base_role_name_input # For submodule
  iam_tf_deploy_role_name_override          = var.runner_module_iam_op_tf_deploy_role_name_input # For submodule
  iam_backup_restore_role_name_override     = var.runner_module_iam_op_backup_restore_role_name_input # For submodule
  iam_submodule_plume_tau_role_arn_to_assume= var.runner_module_iam_plume_tau_role_arn_input # For submodule
  iam_submodule_tags                        = var.runner_module_iam_submodule_tags_input # For submodule

  security_group_base_name                 = "PlumeGitLabRunner" // Or make a variable
  # default_docker_image_for_executor already has a default in module
  # concurrent_jobs_per_instance already has a default in module

  common_module_tags       = var.module_common_tags
  specific_ec2_instance_tags = var.module_specific_ec2_tags
}
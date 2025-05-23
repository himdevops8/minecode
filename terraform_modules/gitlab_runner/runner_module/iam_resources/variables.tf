# File: gitlab-runner-deployment/runner_module/iam_resources/variables.tf

variable "aws_account_id" {
  description = "Current AWS Account ID, used for constructing ARNs in policies."
  type        = string
}

variable "aws_region_for_policies" {
  description = "AWS Region, used in some policy resource ARNs if needed."
  type        = string
}

variable "ec2_instance_role_name_input" { // Renamed for clarity within submodule
  description = "Name for the IAM role the EC2 instances will assume."
  type        = string
}

variable "base_operational_role_name_input" {
  description = "Name for the base operational role."
  type        = string
}

variable "tf_deploy_operational_role_name_input" {
  description = "Name for the TF/Tofu deploy operational role."
  type        = string
}

variable "backup_restore_operational_role_name_input" {
  description = "Name for the backup/restore operational role."
  type        = string
}

variable "gitlab_token_secret_arn_for_ec2_policy_input" {
  description = "ARN of the Secrets Manager secret (for GitLab token) that the EC2 role needs access to."
  type        = string
}

variable "plume_tau_role_arn_for_ec2_to_assume_input" {
  description = "ARN of the plume-tau-dev-use1-terraform role for the EC2 role's assume policy."
  type        = string
}

variable "submodule_common_tags_input" {
  description = "Tags to apply to all IAM roles and policies created by this submodule."
  type        = map(string)
  default     = {}
}
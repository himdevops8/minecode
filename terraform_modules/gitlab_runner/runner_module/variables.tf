# File: plume-gitlab-runner-project/runner_module/variables.tf

variable "aws_region" {
  description = "AWS region where all resources including Secrets Manager secret are located."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the GitLab runners will be deployed."
  type        = string
}

variable "runner_instance_configurations" {
  description = "A list of objects, each defining a GitLab Runner EC2 instance. Required keys: 'name_suffix', 'subnet_id', 'gitlab_runner_name', 'gitlab_runner_tags'. Optional keys: 'instance_type', 'ami_id', 'root_volume_size'."
  type = list(object({
    name_suffix      = string
    subnet_id        = string
    gitlab_runner_name = string
    gitlab_runner_tags = list(string)
    instance_type    = optional(string, "m5a.large")
    ami_id           = optional(string, null)
    root_volume_size = optional(number, 100)
  }))
  nullable = false
  validation {
    condition     = length(var.runner_instance_configurations) > 0
    error_message = "At least one runner instance configuration must be provided."
  }
}

variable "gitlab_instance_url" {
  description = "The base URL of your GitLab instance."
  type        = string
}

variable "gitlab_registration_token_secret_arn" { // Renamed from gitlab_runner_token_secret_arn for clarity
  description = "ARN of the AWS Secrets Manager secret containing the GitLab Runner registration token."
  type        = string
}

variable "default_docker_image_for_executor" {
  description = "Default Docker image for the GitLab runner's Docker executor if not specified in .gitlab-ci.yml."
  type        = string
  default     = "docker-cse.artifactory.se-charter.net/alpine:latest"
}

variable "concurrent_jobs_per_runner_instance" {
  description = "Number of concurrent jobs each individual EC2 runner instance can handle."
  type        = number
  default     = 1
}

variable "security_group_base_name" {
  description = "Base name for the Security Group created for the runners."
  type        = string
  default     = "gitlab-runner-ec2"
}

# --- Inputs for the main EC2 Instance Profile created by THIS module ---
variable "ec2_direct_instance_profile_name_prefix" {
  description = "Prefix for the IAM Instance Profile for the EC2 runners (this module creates this profile)."
  type        = string
  default     = "GitLabRunnerEC2Profile"
}

# --- Inputs that will be passed THROUGH to the iam_resources submodule ---
variable "iam_submodule_ec2_role_name" {
  description = "Exact name for the IAM Role the EC2 instances will run as (created in iam_resources submodule)."
  type        = string
  default     = "plido-builder-role-runner-ec2" // Defaulting to your original role name base
}

variable "iam_submodule_base_role_name" {
  description = "Name for the base operational role (created in iam_resources submodule)."
  type        = string
  default     = "plido-builder-base-role"
}

variable "iam_submodule_tf_deploy_role_name" {
  description = "Name for the TF/Tofu deploy operational role (created in iam_resources submodule)."
  type        = string
  default     = "plido-builder-tf-role"
}

variable "iam_submodule_backup_restore_role_name" {
  description = "Name for the backup/restore operational role (created in iam_resources submodule)."
  type        = string
  default     = "plido-builder-backup-restore-role"
}

variable "iam_submodule_plume_tau_role_arn_to_assume" {
  description = "ARN of the external 'plume-tau-dev-use1-terraform' role for the EC2 role to assume (used in iam_resources submodule policy)."
  type        = string
}

variable "iam_submodule_tags" {
  description = "Tags to apply to IAM resources created by the iam_resources submodule."
  type        = map(string)
  default     = {}
}
# --- End inputs for iam_resources submodule ---

variable "common_module_tags" {
  description = "Common tags to apply to module-created resources (merged with provider default_tags)."
  type        = map(string)
  default     = {}
}

variable "specific_ec2_instance_tags" {
  description = "Additional tags applied ONLY to the EC2 instances."
  type        = map(string)
  default     = {}
}
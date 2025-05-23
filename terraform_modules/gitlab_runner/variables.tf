# File: plume-gitlab-runner-deployment/variables.tf

variable "aws_region" {
  description = "AWS region for deployment."
  type        = string
  default     = "us-east-1"
}

variable "vpc_id_for_runners" {
  description = "VPC ID where the GitLab runners will be deployed."
  type        = string
  // No default - must be provided in terraform.tfvars
}

variable "gitlab_base_url" {
  description = "The base URL of your GitLab instance."
  type        = string
  // No default - must be provided in terraform.tfvars, e.g., "https://gitlab.se-charter.net"
}

variable "gitlab_token_secret_arn" {
  description = "ARN of the AWS Secrets Manager secret containing the GitLab Runner registration token."
  type        = string
  sensitive   = true
  // NO DEFAULT - Must be provided in terraform.tfvars
}

variable "runner_definitions" {
  description = "A list of configurations, one for each GitLab Runner EC2 instance to be created."
  type = list(object({
    name_suffix      = string                 // e.g., "01", "web-app-01" - for resource naming uniqueness
    subnet_id        = string                 // Specific AWS Subnet ID for this runner instance
    gitlab_runner_name = string                 // Description for this runner as seen in GitLab UI (e.g., "plido-builder-01")
    gitlab_runner_tags = list(string)           // Tags for GitLab CI jobs to select this runner (e.g., ["docker", "plido-builder-01"])
    instance_type    = optional(string)       // Optional: EC2 instance type (e.g., "t3.medium"), module has default
    ami_id           = optional(string)       // Optional: Specific AMI ID, module defaults to latest AL2023
    root_volume_size = optional(number)       // Optional: Root disk size in GB, module has default
  }))
  default = [] // This list will be populated in terraform.tfvars
}

variable "root_provider_default_tags" {
  description = "Default tags to be applied by the AWS provider to all taggable resources."
  type        = map(string)
  default = {
    "app_id"     = "APP3921"
    "app_ref_id" = "int99"
    "cost_code"  = "1707100888"
  }
}

variable "module_specific_common_tags" {
  description = "Common tags to pass to the runner_module, applied to resources created by the module."
  type        = map(string)
  default = {
    "TerraformDeployment" = "PlumeGitLabRunners"
    "BillingEntity"       = "SCPDevOps"
  }
}

variable "module_specific_ec2_tags" {
  description = "Additional tags specific ONLY to EC2 instances created by the runner_module."
  type        = map(string)
  default = {
    "WorkloadRole" = "CI-CD-WorkerNode"
  }
}

// Inputs for the runner_module to configure its iam_resources submodule and direct EC2 role
variable "runner_module_iam_ec2_role_name_prefix_input" {
     default = "PlumeGitLabEC2Role" 
     }
     
variable "runner_module_iam_ec2_profile_prefix_input" {
     default = "PlumeGitLabEC2Profile"
      }
      
variable "runner_module_iam_op_roles_suffix_input" {
     default = "-ops"
      }

variable "runner_module_iam_op_base_role_name_input" { 
    default = "PlumeBase" 
    } // Will have suffix appended by module

variable "runner_module_iam_op_tf_deploy_role_name_input" { 
    default = "PlumeTFDeploy" 
    }

variable "runner_module_iam_op_backup_restore_role_name_input" { 
    default = "PlumeBackup" 
    }

variable "runner_module_iam_plume_tau_role_arn_input" { 
    type = string 
    }

variable "runner_module_iam_submodule_tags_input" { 
    type = map(string); default = {"Source"="IAMSubmoduleFromRoot"
    } 
    }
# File: plume-gitlab-runner-deployment/outputs.tf

output "deployed_gitlab_runner_details" {
  description = "A list containing details for each deployed GitLab Runner EC2 instance."
  value       = module.gitlab_runners_deployment.runner_ec2_instance_details
}

output "gitlab_runner_ec2_instance_role_arn" {
  description = "The ARN of the IAM role directly assumed by the EC2 runner instances."
  value       = module.gitlab_runners_deployment.ec2_instance_role_arn
}

output "gitlab_runner_security_group_id" {
  description = "The ID of the Security Group created for the GitLab runners."
  value       = module.gitlab_runners_deployment.security_group_id_for_runners
}

output "operational_roles_arns" {
  description = "ARNs of the operational IAM roles created by the runner module for CI jobs to assume."
  value = {
    base_role_arn            = module.gitlab_runners_deployment.operational_base_role_arn
    tf_deploy_role_arn       = module.gitlab_runners_deployment.operational_tf_deploy_role_arn
    backup_restore_role_arn  = module.gitlab_runners_deployment.operational_backup_restore_role_arn
  }
}
# File: gitlab-runner-deployment/runner_module/iam_resources/outputs.tf

output "created_ec2_instance_role_name" {
  description = "Name of the IAM role created for the EC2 instances to run as."
  value       = aws_iam_role.gitlab_runner_ec2_instance_role.name
}

output "created_ec2_instance_role_arn" {
  description = "ARN of the IAM role created for the EC2 instances to run as."
  value       = aws_iam_role.gitlab_runner_ec2_instance_role.arn
}

output "created_base_operational_role_arn" {
  description = "ARN of the created base_operational_role."
  value       = aws_iam_role.base_operational_role.arn
}

output "created_tf_deploy_operational_role_arn" {
  description = "ARN of the created tf_deploy_operational_role."
  value       = aws_iam_role.tf_deploy_operational_role.arn
}

output "created_backup_restore_operational_role_arn" {
  description = "ARN of the created backup_restore_operational_role."
  value       = aws_iam_role.backup_restore_operational_role.arn
}
# File: plume-gitlab-runner-project/runner_module/outputs.tf

output "runner_ec2_instance_details" {
  description = "Details of the created GitLab Runner EC2 instances."
  value = [
    for key, inst in aws_instance.gitlab_runner_ec2 : {
      instance_id        = inst.id
      private_ip         = inst.private_ip
      public_ip          = inst.public_ip
      arn                = inst.arn
      ec2_name_tag       = inst.tags["Name"]
      gitlab_runner_name = local.runners_map[key].gitlab_runner_name
    }
  ]
}

output "ec2_instance_role_arn_output" {
  description = "ARN of the IAM role directly assumed by the EC2 runner instances."
  value       = module.iam_roles_submodule.created_ec2_instance_role_arn
}

output "ec2_instance_profile_name_output" {
  description = "Name of the IAM instance profile for the EC2 runner instances."
  value       = aws_iam_instance_profile.runner_ec2_module_profile.name
}

output "security_group_id_for_runners_output" {
  description = "ID of the Security Group created for the GitLab runners."
  value       = aws_security_group.gitlab_runner_sg.id
}

output "operational_roles_arns_output" {
  description = "ARNs of the operational IAM roles created by this module for CI jobs to assume."
  value = {
    base_role_arn            = module.iam_roles_submodule.created_base_operational_role_arn
    tf_deploy_role_arn       = module.iam_roles_submodule.created_tf_deploy_operational_role_arn
    backup_restore_role_arn  = module.iam_roles_submodule.created_backup_restore_operational_role_arn
  }
}
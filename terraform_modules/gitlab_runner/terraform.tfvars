// File: plume-gitlab-runner-deployment/terraform.tfvars

// REQUIRED: Update with your AWS Secret ARN for the GitLab Runner token
gitlab_token_secret_arn = "arn:aws:secretsmanager:us-east-1:YOUR_ACCOUNT_ID:secret:YOUR_GITLAB_TOKEN_SECRET_NAME-XXXXXX"

// REQUIRED: Update with your VPC ID
vpc_id_for_runners = "vpc-0560dd8a2acc794c4" // Your actual VPC ID

// REQUIRED: Update with your GitLab instance URL
gitlab_base_url = "https://gitlab.spectrumflow.net/" // Or https://gitlab.se-charter.net/

// REQUIRED: ARN of the plume-tau-dev-use1-terraform role
external_plume_tau_role_arn = "arn:aws:iam::YOUR_ACCOUNT_ID:role/plume-tau-dev-use1-terraform"


// --- Define your 3, 4, or 5 runner instances here ---
runner_definitions = [
  {
    name_suffix        = "01"                                     // Unique suffix for resource names
    subnet_id          = "subnet-YOUR_PRIVATE_SUBNET_ID_FOR_AZ_A" // e.g., subnet in us-east-1a
    gitlab_runner_name = "plido-builder-az-a-01"                  // Name/Description seen in GitLab UI
    gitlab_runner_tags = ["docker", "linux", "plido-builder-az-a-01"] // Tags for CI jobs
    instance_type      = "m5a.large"                              // Optional: overrides module default
    # ami_id           = "ami-xxxxxxxxxxxxxxxxx"                  // Optional: to use a specific AMI
    # root_volume_size = 120                                    // Optional: overrides module default
  },
  {
    name_suffix        = "02"
    subnet_id          = "subnet-YOUR_PRIVATE_SUBNET_ID_FOR_AZ_B" // e.g., subnet in us-east-1b
    gitlab_runner_name = "plido-builder-az-b-01"
    gitlab_runner_tags = ["docker", "linux", "plido-builder-az-b-01"]
    instance_type      = "m5a.large"
  },
  {
    name_suffix        = "03"
    subnet_id          = "subnet-YOUR_PRIVATE_SUBNET_ID_FOR_AZ_C" // e.g., subnet in us-east-1c
    gitlab_runner_name = "plido-builder-az-c-01"
    gitlab_runner_tags = ["docker", "linux", "plido-builder-az-c-01"]
    instance_type      = "m5a.large"
  }
  // To create 5 instances, add two more blocks similar to the above,
  // ensuring 'name_suffix' is unique and 'subnet_id' points to desired (preferably different AZ) subnets.
  // Example for a 4th runner:
  // {
  //   name_suffix        = "04"
  //   subnet_id          = "subnet-YOUR_PRIVATE_SUBNET_ID_FOR_AZ_D" // e.g., subnet in us-east-1d
  //   gitlab_runner_name = "plido-builder-az-d-01"
  //   gitlab_runner_tags = ["docker", "linux", "plido-builder-az-d-01"]
  //   instance_type      = "m5a.large"
  // },
  // Example for a 5th runner (could reuse an AZ if you only have 4 AZs with suitable subnets):
  // {
  //   name_suffix        = "05"
  //   subnet_id          = "subnet-YOUR_PRIVATE_SUBNET_ID_FOR_AZ_A_ALT" // Another subnet, could be same AZ as 01
  //   gitlab_runner_name = "plido-builder-az-a-02" // Make name distinct
  //   gitlab_runner_tags = ["docker", "linux", "plido-builder-az-a-02"]
  //   instance_type      = "m5a.large"
  // }
]

// --- Optional Overrides for Root Variables (uncomment and change if needed) ---
// aws_region = "us-east-1"
//
// module_specific_common_tags = {
//   "CustomRootTag" = "RunnerDeploymentV2"
// }
//
// module_specific_ec2_tags = {
//   "BillingCodeOverride" = "XYZ789"
// }
//
// runner_module_iam_role_name_prefix_main = "MyOrg-GitLabRunnerEC2"
// ... any other root variables you want to override from their defaults ...
# File: plume-gitlab-runner-project/runner_module/main.tf

data "aws_ami" "latest_amazon_linux_2023" {
  count = length([for config in var.runner_instance_configurations : config if config.ami_id == null || config.ami_id == ""]) > 0 ? 1 : 0

  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# This data source is used by the templatefile function for user_data
data "aws_caller_identity" "current_for_user_data" {}


locals {
  default_ami_id_lookup = length(data.aws_ami.latest_amazon_linux_2023) > 0 ? data.aws_ami.latest_amazon_linux_2023[0].id : null

  runners_map = {
    for i, config in var.runner_instance_configurations : tostring(i) => {
      name_suffix        = config.name_suffix
      subnet_id          = config.subnet_id
      gitlab_runner_name = config.gitlab_runner_name
      gitlab_runner_tags = config.gitlab_runner_tags
      instance_type      = coalesce(config.instance_type, "m5a.large")
      ami_id             = coalesce(config.ami_id, local.default_ami_id_lookup, "ami-0ae8f15ae66fe8cda") # Fallback
      root_volume_size   = coalesce(config.root_volume_size, 100)
      ec2_name_tag       = "${config.gitlab_runner_name}-${config.name_suffix}"
    }
  }
}

data "cloudinit_config" "runner_user_data_rendered" { # Renamed for clarity
  for_each = local.runners_map

  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    filename     = "user_data.sh"
    content = templatefile("${path.module}/user_data.tftpl", {
      aws_account_id_from_tf                      = data.aws_caller_identity.current_for_user_data.account_id
      aws_region_from_tf                          = var.aws_region
      gitlab_url_from_tf                          = var.gitlab_instance_url
      gitlab_secret_arn_from_tf                   = var.gitlab_registration_token_secret_arn
      default_docker_image_from_tf                = var.default_docker_image_for_executor
      gitlab_runner_name_from_tf                  = each.value.gitlab_runner_name
      gitlab_runner_tags_comma_separated_from_tf  = join(",", each.value.gitlab_runner_tags)
      concurrent_jobs_from_tf                     = var.concurrent_jobs_per_runner_instance
    })
  }
}

resource "aws_instance" "gitlab_runner_ec2" {
  for_each = local.runners_map

  ami           = each.value.ami_id
  instance_type = each.value.instance_type
  subnet_id     = each.value.subnet_id
  user_data_base64 = data.cloudinit_config.runner_user_data_rendered[each.key].rendered

  iam_instance_profile = aws_iam_instance_profile.runner_ec2_module_profile.name // From runner_module/iam.tf

  vpc_security_group_ids = [aws_security_group.gitlab_runner_sg.id] // From runner_module/sg.tf

  root_block_device {
    volume_size           = each.value.root_volume_size
    volume_type           = "gp3"
    iops                  = 3000
    delete_on_termination = true
  }

  tags = merge(var.common_module_tags, var.specific_ec2_instance_tags, {
    Name        = each.value.ec2_name_tag
    Team        = "chtr-plido"    // From your original tags
    Environment = "globaldev"     // From your original tags
    Stack       = "plume-tau"     // From your original tags
    CreatedBy   = "TerraformRunnerModule" // Module specific
  })

  depends_on = [
    aws_iam_instance_profile.runner_ec2_module_profile,
  ]
}
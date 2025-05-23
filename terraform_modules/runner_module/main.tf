data "aws_ami" "latest_amazon_linux" {
  count = length([for c in var.runner_instances_config : c if c.ami_id == null || c.ami_id == ""]) > 0 ? 1 : 0

  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"] # Defaulting to AL2023 as per your original file
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

data "aws_caller_identity" "current" {} // For aws_account_id in user_data

locals {
  default_ami_id = length(data.aws_ami.latest_amazon_linux) > 0 ? data.aws_ami.latest_amazon_linux[0].id : null

  processed_runner_configs_with_ami = [
    for i, config in var.runner_instances_config : {
      name_suffix      = config.name_suffix
      subnet_id        = config.subnet_id
      instance_type    = coalesce(config.instance_type, "m5a.large") // Ensure defaults if optional not set
      ami_id           = coalesce(config.ami_id, local.default_ami_id, "ami-0ae8f15ae66fe8cda") // Final fallback
      root_volume_size = coalesce(config.root_volume_size, 100)
      gr_name          = config.gr_name
      runner_ec2_name  = "${config.gr_name}-${config.name_suffix}" // For EC2 Name tag
      gr_tags          = config.gr_tags
    }
  ]
}

data "cloudinit_config" "runner_user_data" {
  for_each = { for i, config in local.processed_runner_configs_with_ami : i => config }

  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    filename     = "user_data.sh"
    content = templatefile("${path.module}/user_data.tftpl", {
      aws_account_id                   = data.aws_caller_identity.current.account_id
      aws_region                       = var.aws_region
      gr_url                           = var.gitlab_url
      gitlab_secret_arn                = var.gitlab_runner_token_secret_arn
      default_docker_image_executor    = var.default_docker_image_for_runner_executor
      gr_name_for_gitlab_registration  = each.value.gr_name // Name for GitLab Runner description
      runner_tags_list_comma_separated = join(",", each.value.gr_tags)
      concurrent_jobs_count            = var.concurrent_jobs_per_instance
    })
  }
}

resource "aws_instance" "gitlab_runner" {
  for_each = { for i, config in local.processed_runner_configs_with_ami : i => config }

  ami           = each.value.ami_id
  instance_type = each.value.instance_type
  subnet_id     = each.value.subnet_id
  user_data_base64 = data.cloudinit_config.runner_user_data[each.key].rendered

  iam_instance_profile = local.effective_instance_profile_name_for_ec2 # From iam.tf

  vpc_security_group_ids = [aws_security_group.runner_sg.id]

  root_block_device {
    volume_size = each.value.root_volume_size
    volume_type = "gp3"
    iops        = 3000 # Consider making this configurable
  }

  tags = merge(var.common_tags, var.additional_ec2_tags, {
    Name = each.value.runner_ec2_name
  })

  depends_on = [
    var.iam_role_arn_existing == null && length(aws_iam_instance_profile.runner_profile) > 0 ? aws_iam_instance_profile.runner_profile[0] : null,
  ].compact() # Ensure profile is created if module manages it
}
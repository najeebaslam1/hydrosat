locals {
  aws_secret_name   = "aws-credentials"
  docker_repo_name  = "najeebrgn"
  docker_repo       = "hydrosat"
  docker_image_tag  = "latest"
  docker_image_name = "${local.docker_repo_name}/${local.docker_repo}:${local.docker_image_tag}"
}


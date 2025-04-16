module "dagster" {
  source      = "./modules/dagster"
  secret_name = local.aws_secret_name
  namespace   = "default"

  data = {
    AWS_ACCESS_KEY_ID     = var.aws_access_key_id
    AWS_SECRET_ACCESS_KEY = var.aws_secret_access_key
    AWS_DEFAULT_REGION    = var.aws_default_region
  }
  docker_username   = var.docker_username
  docker_password   = var.docker_password
  s3_bucket         = var.s3_bucket
  aws_region        = var.aws_region
  docker_image_name = local.docker_image_name

}

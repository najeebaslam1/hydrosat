resource "helm_release" "dagster" {
  name       = "dagster"
  repository = "https://dagster-io.github.io/helm"
  chart      = "dagster"

  values = [
    "${file("helm/values.yaml")}"
  ]

  # Set environment variable S3_BUCKET
  # Set environment variable S3_BUCKET
  set {
    name  = "dagster-user-deployments.deployments[0].env[0].name"
    value = "S3_BUCKET"
  }

  set {
    name  = "dagster-user-deployments.deployments[0].env[0].value"
    value = var.s3_bucket
  }

  # Set environment variable AWS_REGION
  set {
    name  = "dagster-user-deployments.deployments[0].env[1].name"
    value = "AWS_REGION"
  }

  set {
    name  = "dagster-user-deployments.deployments[0].env[1].value"
    value = var.aws_region
  }
}


resource "kubernetes_secret" "aws_secrets" {
  metadata {
    name      = var.secret_name
    namespace = var.namespace
  }
  data = {
    for key, value in var.data : key => base64decode(value)
  }
  type = "Opaque"
}

provider "docker" {
  registry_auth {
    address  = "index.docker.io/v1/"
    username = var.docker_username
    password = var.docker_password
  }
}

resource "docker_image" "hydrosat" {
  name = var.docker_image_name
  build {
    context    = "${path.module}/../../../app"
    dockerfile = "Dockerfile"
  }
}

# # Push Docker image to Docker Hub
resource "null_resource" "push_image" {
  depends_on = [docker_image.hydrosat]

  provisioner "local-exec" {
    command = "docker push ${docker_image.hydrosat.name}"
  }
}

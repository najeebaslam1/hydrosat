variable "secret_name" {
  description = "Name of the Kubernetes secret"
  type        = string
}

variable "namespace" {
  description = "Namespace for the secret"
  type        = string
  default     = "default"
}

variable "data" {
  description = "A map of key/value pairs to store in the secret"
  type        = map(string)
}

variable "docker_username" {
  description = "Docker username"
  type        = string
}

variable "docker_password" {
  description = "Docker password"
  type        = string
}

variable "docker_image_name" {
  description = "Docker image name"
  type        = string

}

variable "s3_bucket" {
  description = "S3 bucket name"
  type        = string

}

variable "aws_region" {
  description = "Aws region"
  type        = string

}



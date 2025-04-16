variable "aws_access_key_id" {
  description = "AWS Access Key ID"
  type        = string
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key"
  type        = string
}

variable "aws_default_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-west-1"
}


variable "docker_username" {
  description = "Docker username"
  type        = string
}

variable "docker_password" {
  description = "Docker password"
  type        = string
}

variable "s3_bucket" {
  description = "Docker password"
  type        = string
}

variable "aws_region" {
  description = "Docker password"
  type        = string
}

variable "region" {
  type = "string"
}

variable "vpc_name" {
  type = "string"
}

variable "env" {
  description = "The name of the env, i.e. dev"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  default     = {}
}

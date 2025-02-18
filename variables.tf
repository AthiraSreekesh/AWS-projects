variable "region" {
  description = "Region of AWS account"
  type        = string
}

variable "project_name" {
  description = "Project tag value"
  type        = string
}

variable "environment" {
  description = "environment tag value"
  type        = string
}

variable "owner" {
  description = "owner tag value"
  type        = string
}

variable "names" {
  description = "name of security group and insatnce to be created"
  type        = list
}
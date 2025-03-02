variable "project_name" {
  description = "Project tag value"
  type        = string
}

variable "environment" {
  description = "environment tag value"
  type        = string
}

variable "cidr_block" {
  description = "cidr block of VPC"
  type        = string
}

variable "public_subnets" {
  description = "number of public subnets"
  type        = string
}

variable "private_subnets" {
  description = "number of private subnets"
  type        = string
}
variable "new_bits" {
  description = "new bits to be added for subnetting"
  type        = string
}
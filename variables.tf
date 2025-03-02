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
  type        = list(any)
}

variable "webserver_sg_ports" {
  description = "inbound ports of web server sg"
  type        = list(any)
}

variable "db_sg_ports" {
  description = "inbound ports of db server sg"
  type        = list(any)
}

variable "web_instance_type" {
  description = "web instance type"
  type        = string
}


variable "web_instance_ami" {
  description = "web instance ami"
  type        = string
}

variable "user_data_replacement" {
  description = "boolian to set user data replacement status"
  type        = bool
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
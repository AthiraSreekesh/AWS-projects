data "aws_key_pair" "key_name" {
  filter {
    name = "tag:Name"
    values = ["${var.project_name}-${var.environment}"]
  }
}
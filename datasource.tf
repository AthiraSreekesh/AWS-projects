data "aws_ami" "ami" {
  name_regex       = "^al2023-ami-2023\\.6\\.20250218\\.2-kernel-6\\.1-x86_64$" 
}
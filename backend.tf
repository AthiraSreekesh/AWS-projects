terraform {
  backend "s3" {
    bucket = "mygits3bucket"
    key    = "lamp/terraform-state"
    region = "eu-north-1"
  }
}

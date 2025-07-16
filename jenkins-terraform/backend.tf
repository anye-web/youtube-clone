terraform {
  backend "s3" {
    bucket = "janoh-jenkins"
    key    = "jenkins/terraform.tfstate"
    region = "us-east-1"
  }
}

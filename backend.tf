terraform {
  backend "s3" {
    bucket         = "develtime-states"
    encrypt        = false
    key            = "terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
  }
}

terraform {
  backend "s3" {
    # These values should match the outputs from infra/global/backend
    # After running terraform apply in global/backend, update these values:
    bucket         = "url-shortener-ecs-bucket-efbfa315"  # From global/backend output
    key            = "dev/terraform.tfstate"
    region         = "eu-west-2"                         # Match your global/backend region
    dynamodb_table = "terraform-state-lock"              # Match your global/backend table name
    encrypt        = true
  }
}

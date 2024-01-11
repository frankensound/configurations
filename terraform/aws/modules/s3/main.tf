resource "aws_s3_bucket" "my_bucket" {
  bucket = "myfrankenbucket"

  tags = {
    Name        = "MyS3Bucket"
    Environment = "Development"
  }
}
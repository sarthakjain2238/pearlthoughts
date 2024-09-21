variable "ec2_key_pair" {
  description = "The name of the EC2 key pair for SSH access"
  type        = string
  default     = "new"
}

variable "aws_region" {
  description = "The AWS region to deploy to"
  default     = "ap-south-1"
}
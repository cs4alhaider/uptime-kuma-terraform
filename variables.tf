# Define the AWS region where the instance will be deployed
variable "region" {
  description = "The AWS region to deploy the instance in"
  type        = string
  default     = "me-central-1"
}

# Define the instance type for the EC2 instance
variable "instance_type" {
  description = "The instance type to use"
  type        = string
  default     = "t3.micro"
}

# Define the AMI ID for the EC2 instance
variable "ami_id" {
  description = "The AMI ID to use for the instance"
  type        = string
  default     = "ami-07c6e9800ad06bb32"  # Replace with the latest Amazon Linux 2023 AMI ID for your selected region
}

# Define the name of the key pair to be used for the instance
variable "key_name" {
  description = "The name of the key pair to use for the instance"
  type        = string
  default     = "uptime_kuma_key"
}

# Define the path to the public key file for the key pair
variable "public_key_path" {
  description = "The path to the public key file"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

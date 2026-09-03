variable "project_name" {
  description = "Project name"
  type        = string
  default     = "expense"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)

  default = {
    Project     = "expense"
    Environment = "dev"
    Terraform   = "true"
  }
}

variable "zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
  default     = "Z00916842MCDX0S5FWPWY"
}

variable "domain_name" {
  description = "Route53 domain name"
  type        = string
  default     = "hariawsdevops.online"
}

variable "instance_type" {
  description = "Backend EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "backend_port" {
  description = "Backend application port"
  type        = number
  default     = 8080
}
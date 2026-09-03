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
  description = "Common tags for all resources"
  type        = map(string)

  default = {
    Project     = "expense"
    Environment = "dev"
    Terraform   = "true"
  }
}

variable "zone_id" {
  description = "Route53 Hosted Zone ID"
  type        = string
  default     = "Z00916842MCDX0S5FWPWY"
}

variable "domain_name" {
  description = "Application domain name"
  type        = string
  default     = "hariawsdevops.online"
}

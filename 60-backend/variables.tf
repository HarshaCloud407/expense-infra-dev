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
variable "project_name" {
  default = "expense"
}

variable "environment" {
  default = "dev"
}

variable "common_tags" {
  default = {
    Project     = "expense"
    Environment = "dev"
    Terraform   = "true"
  }
}

variable "zone_id" {
  default = "Z00916842MCDX0S5FWPWY"
}

variable "domain_name" {
  default = "hariawsdevops.online"
}

# RDS MySQL password
variable "db_password" {
  description = "ExpenseApp@1"
  type        = string
  sensitive   = true
}
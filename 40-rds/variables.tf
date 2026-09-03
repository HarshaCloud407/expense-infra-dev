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

# ---------------------------------------------------------
# RDS MySQL Master Password
# ---------------------------------------------------------
variable "db_password" {
  description = "Master password for RDS MySQL database"
  type        = string
  sensitive   = true
}

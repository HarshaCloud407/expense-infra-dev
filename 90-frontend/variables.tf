variable "project_name" {
  type    = string
  default = "expense"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "instance_type" {
  description = "Frontend EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "domain_name" {
  type    = string
  default = "hariawsdevops.online"
}

variable "zone_id" {
  type    = string
  default = "Z00916842MCDX0S5FWPWY"
}

variable "common_tags" {
  type = map(string)

  default = {
    Project     = "expense"
    Environment = "dev"
    Terraform   = "true"
  }
}
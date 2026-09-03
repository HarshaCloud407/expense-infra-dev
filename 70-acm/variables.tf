variable "project_name" {
    default = "expense"
}

variable "environment" {
    default = "dev"
}

variable "common_tags" {
    default = {
        Project = "expense"
        Environment = "dev"
        Terraform = "true"
    }
}

variable "domain_name" {
    default = "hariawsdevops.online"
}

variable "zone_id" {
    default = "Z00916842MCDX0S5FWPWY"
}
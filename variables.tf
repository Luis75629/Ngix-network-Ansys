variable "region" {
  type        = string
  default     = "us-east-1"
  description = "Region"
}


variable "ip_vpc" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR VPC"
}

locals {
  environment = "Dev"
  project     = "onscale"

}

variable "subnet_ip" {
  type = list(string)
  default = ["10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.11.0/24",
    "10.0.12.0/24",
    "10.0.13.0/24"
  ]
  description = "CIDR for subnet"
}
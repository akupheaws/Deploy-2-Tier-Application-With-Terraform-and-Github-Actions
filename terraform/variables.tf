variable "domain_name" {
  description = "Domain name for the application"
  type        = string
  default     = "akuphecloud.com"
}

variable "route53_zone_id" {
  description = "ID of the existing Route 53 hosted zone"
  type        = string
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}

variable "key_pair_name" {
  description = "EC2 key pair name"
  type        = string
  default     = "bastion-host-key"
}

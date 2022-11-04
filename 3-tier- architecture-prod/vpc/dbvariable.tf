

variable "engine_name" {
  description = "Enter the DB engine"
  type        = string
  default     = "MariaDB"
}
variable "db_name" {
  description = "Enter the name of the database to be created inside DB Instance"
  type        = string
  default     = "db"
}
variable "user_name" {
  description = "Enter the username for DB"
  type        = string
  default     = "admin"
}
variable "pass" {
  description = "Enter the username for DB"
  type        = string
  default     = "admin.123"
}


/*
variable "multi_az_deployment" {
  description = "Enable or disable multi-az deployment"
  type        = bool
  default     = false
}

*/


variable "public_access" {
  description = "Whether public access needed"
  type        = bool
  default     = false
}


variable "delete_automated_backup" {
  type    = bool
  default = true
}

variable "instance_class" {
  type    = string
  default = "db.t2.micro"
}

variable "skip_finalSnapshot" {
  type    = bool
  default = true
}

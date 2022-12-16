variable "developer-trusted-entities" {
  type        = list(string)
  description = "List of IAM user ARNs who can assume the Develpoer role"
}

variable "sys_admin-trusted-entities" {
  type        = list(string)
  description = "List of IAM user ARNs who can assume the System Admin role"
}

variable "developer-role-name" {
  type = string
  description = "The name of the Developer Role name"
  default = "developer"
}

variable "sys_admin-role-name" {
  type = string
  description = "The name of the System Admin Role name"
  default = "sys_admin"
}

variable "org" {
  type        = string
  default = "managed-users"
  description = "The name of a group of managed users"
}

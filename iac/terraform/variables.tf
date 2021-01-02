variable "location" {
  type = string
}

variable "identifier" {
  type        = string
  description = "String that identify your resources."
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "identifier" {
  type = string
}

variable "environment" {
  type = string
}

variable "resource_group" {
  type = object({
    location = string
    name     = string
  })
}

variable "virtual_network_subnets" {
  type = object({
    app = object({
      id = string
    })
  })
}

variable "log_analytics_workspace" {
  type = object({
    id   = string
    name = string
  })
}

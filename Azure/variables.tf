#AzureRM
variable "subscription_id" {
  description = ""
  default     = ""
}

variable "client_id" {
  description = ""
  default     = ""
}

variable "client_secret" {
  description = ""
  default     = ""
}

variable "tenant_id" {
  description = ""
  default     = ""
}

variable "resource_group_name" {
  description = "Resource Group"
}

variable "location" {
  description = ""
}

variable "vnet_cidr" {
  description = "Virtual Network"
  default     = "ReactorNetwork1"
}

variable "subnet1_cidr" {
  description = "Subnet 1"
  default     = "10.0.0.0/24"
}

variable "subnet2_cidr" {
  description = "Subnet 2"
  default     = "192.168.0.0/16"
}

variable "environment" {
  description = "Define the environment to deploy to"
}

variable "vm_username" {
  description = ""
  default     = "azure-admin"
}

variable "vm_password" {
  description = ""
  default     = "Pentium4"
}

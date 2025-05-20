variable "assignments" {
  description = "Map of role assignments"
  type = map(object({
    principal_id = string
    role         = string
    scope        = string
  }))
}

variable "create_custom_role" {
  type        = bool
  description = "Whether to create a custom role"
  default     = false
}

variable "custom_role_name" {
  type        = string
  description = "Name of the custom role"
  default     = ""
}

variable "custom_role_description" {
  type        = string
  description = "Description of the custom role"
  default     = ""
}

variable "custom_role_scope" {
  type        = string
  description = "Scope for the custom role"
  default     = ""
}

variable "custom_role_actions" {
  type        = list(string)
  description = "List of actions for the custom role"
  default     = []
}

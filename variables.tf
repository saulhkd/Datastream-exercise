variable "project_id" {
  description = "ID del proyecto de GCP"
  type        = string
}

variable "region" {
  description = "Región para los recursos"
  type        = string
  default     = "europe-west1"
}

variable "db_name" {
  description = "Nombre de la base de datos"
  type        = string
  default     = "appdb"
}

variable "db_user" {
  description = "Usuario de la base de datos"
  type        = string
  default     = "app_user"
}

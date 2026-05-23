provider "google" {
  project = var.project_id
  region  = var.region
}

resource "random_password" "db_password" {
  length  = 20
  special = true
}

resource "google_sql_database_instance" "postgres" {
  name             = "datastream-source-instance"
  database_version = "POSTGRES_15"
  region           = var.region

  settings {
    tier              = "db-custom-1-3840"
    availability_type = "ZONAL"
    disk_size         = 10
    disk_type         = "PD_SSD"

    # Necesario para que Datastream pueda usar replicación lógica
    database_flags {
      name  = "cloudsql.logical_decoding"
      value = "on"
    }

    ip_configuration {
      ipv4_enabled = true
      authorized_networks {
        name  = "allow-all-temp"
        value = "0.0.0.0/0" # solo para desarrollo; restringir en prod
      }
    }

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
    }
  }

  deletion_protection = false
}

resource "google_sql_database" "appdb" {
  name     = var.db_name
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "app_user" {
  name     = var.db_user
  instance = google_sql_database_instance.postgres.name
  password = random_password.db_password.result
}

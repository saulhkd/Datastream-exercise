output "instance_connection_name" {
  description = "Nombre de conexión del Cloud SQL (project:region:instance) para el Python Connector"
  value       = google_sql_database_instance.postgres.connection_name
}

output "instance_public_ip" {
  description = "IP pública del Cloud SQL"
  value       = google_sql_database_instance.postgres.public_ip_address
}

output "db_user" {
  value = google_sql_user.app_user.name
}

output "db_password" {
  value     = random_password.db_password.result
  sensitive = true
}

output "db_name" {
  value = google_sql_database.appdb.name
}

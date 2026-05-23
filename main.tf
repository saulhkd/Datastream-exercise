# 1. Perfil de conexión para la base de datos origen (PostgreSQL)
resource "google_datastream_connection_profile" "postgres_source" {
  display_name          = "Postgres Source DB"
  location              = "europe-west1"
  connection_profile_id = "postgres-source-profile"

  postgresql_profile {
    hostname = "IP_DE_TU_BASE_DE_DATOS" # IP pública o privada
    port     = 5432
    username = "tu_usuario_db"
    password = "tu_password_seguro"
    database = "nombre_de_tu_db"
  }
}

# 2. Perfil de conexión para el destino (BigQuery)
resource "google_datastream_connection_profile" "bigquery_dest" {
  display_name          = "BigQuery Destination"
  location              = "europe-west1"
  connection_profile_id = "bigquery-dest-profile"

  bigquery_profile {}
}

# 3. El Stream de datos que conecta ambos perfiles
resource "google_datastream_stream" "postgres_to_bq" {
  display_name  = "Postgres to BigQuery Stream"
  location      = "europe-west1"
  stream_id     = "postgres-to-bq-stream"

  source_config {
    source_connection_profile = google_datastream_connection_profile.postgres_source.id
    postgresql_source_config {
      publication      = "datastream_publication"
      replication_slot = "datastream_slot"
    }
  }

  destination_config {
    destination_connection_profile = google_datastream_connection_profile.bigquery_dest.id
    bigquery_destination_config {
      data_freshness = "0s"
      single_target_dataset {
        dataset_id = "tu_dataset_destino_en_bq"
      }
    }
  }
}
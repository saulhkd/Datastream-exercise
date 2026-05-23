"""
Genera texto aleatorio y lo guarda en una tabla de Cloud SQL (PostgreSQL).

Variables de entorno requeridas:
  INSTANCE_CONNECTION_NAME  -> salida 'instance_connection_name' de Terraform
                               (formato: project:region:instance)
  DB_USER                   -> usuario de la BD
  DB_PASSWORD               -> contraseña de la BD
  DB_NAME                   -> nombre de la BD

Autenticación: usa Application Default Credentials.
  gcloud auth application-default login
"""

import os
import random
import string
import time
from datetime import datetime, timezone

from dotenv import load_dotenv
from google.cloud.sql.connector import Connector, IPTypes
import pg8000.dbapi

load_dotenv()


def generate_text(min_words: int = 8, max_words: int = 20) -> str:
    vocab = [
        "datos", "pipeline", "stream", "evento", "cliente", "registro",
        "transaccion", "analitica", "modelo", "metrica", "nube", "consulta",
        "tabla", "esquema", "ingesta", "procesado", "tiempo", "real",
    ]
    n = random.randint(min_words, max_words)
    words = random.choices(vocab, k=n)
    sentence = " ".join(words).capitalize() + "."
    suffix = "".join(random.choices(string.ascii_lowercase + string.digits, k=6))
    return f"{sentence} [{suffix}]"


def get_connection():
    connector = Connector()
    conn = connector.connect(
        os.environ["INSTANCE_CONNECTION_NAME"],
        "pg8000",
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        db=os.environ["DB_NAME"],
        ip_type=IPTypes.PUBLIC,
    )
    return connector, conn


def ensure_table(cursor) -> None:
    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS generated_text (
            id          BIGSERIAL PRIMARY KEY,
            content     TEXT NOT NULL,
            created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
        )
        """
    )


def insert_row(cursor, content: str, created_at: datetime) -> None:
    cursor.execute(
        "INSERT INTO generated_text (content, created_at) VALUES (%s, %s)",
        (content, created_at),
    )


def main(interval_seconds: float = 10.0) -> None:
    connector, conn = get_connection()
    try:
        with conn.cursor() as cur:
            ensure_table(cur)
        conn.commit()

        print(f"Insertando una fila cada {interval_seconds:g}s. Ctrl+C para detener.")
        while True:
            content = generate_text()
            created_at = datetime.now(timezone.utc)
            with conn.cursor() as cur:
                insert_row(cur, content, created_at)
            conn.commit()
            print(f"[{created_at.isoformat()}] insertado: {content}")
            time.sleep(interval_seconds)
    except KeyboardInterrupt:
        print("\nInterrumpido por el usuario.")
    finally:
        conn.close()
        connector.close()


if __name__ == "__main__":
    main(interval_seconds=float(os.environ.get("INTERVAL_SECONDS", "10")))

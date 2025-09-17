from flask import Flask, request, jsonify
import os
from psycopg2.pool import SimpleConnectionPool
from psycopg2.extras import RealDictCursor

# REQUIRED env vars (must be set by IaC/user-data/SSM). If missing, crash.
DB_HOST = os.environ["DB_HOST"]
DB_PORT = int(os.environ.get("DB_PORT", "5432"))
DB_NAME = os.environ["DB_NAME"]
DB_USER = os.environ["DB_USER"]
DB_PASSWORD = os.environ["DB_PASSWORD"]

# Create a tiny connection pool at startup. If it fails, app fails (good).
pool = SimpleConnectionPool(
    minconn=1,
    maxconn=5,
    host=DB_HOST,
    port=DB_PORT,
    dbname=DB_NAME,
    user=DB_USER,
    password=DB_PASSWORD,
    connect_timeout=5,
    sslmode="require",  # RDS TLS
)

app = Flask(__name__)

@app.route("/health", methods=["GET"])
def health():
    return jsonify(status="ok"), 200

@app.route("/db/health", methods=["GET"])
def db_health():
    conn = pool.getconn()
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT 1;")
            cur.fetchone()
        return jsonify(db="ok"), 200
    finally:
        pool.putconn(conn)

@app.route("/items", methods=["GET"])
def list_items():
    conn = pool.getconn()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT id, name, created_at FROM items ORDER BY id;")
            return jsonify(items=cur.fetchall()), 200
    finally:
        pool.putconn(conn)

@app.route("/items", methods=["POST"])
def create_item():
    data = request.get_json(silent=True) or {}
    name = (data.get("name") or "").strip()
    if not name:
        return jsonify(error="name is required"), 400

    conn = pool.getconn()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(
                "INSERT INTO items (name) VALUES (%s) RETURNING id, name, created_at;",
                (name,),
            )
            row = cur.fetchone()
            conn.commit()
            return jsonify(row), 201
    finally:
        pool.putconn(conn)

@app.route("/items/<int:item_id>", methods=["GET"])
def get_item(item_id):
    conn = pool.getconn()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT id, name, created_at FROM items WHERE id=%s;", (item_id,))
            row = cur.fetchone()
            if not row:
                return jsonify(error="not found"), 404
            return jsonify(row), 200
    finally:
        pool.putconn(conn)

@app.route("/items/<int:item_id>", methods=["DELETE"])
def delete_item(item_id):
    conn = pool.getconn()
    try:
        with conn.cursor() as cur:
            cur.execute("DELETE FROM items WHERE id=%s;", (item_id,))
            deleted = cur.rowcount
            conn.commit()
            return jsonify(deleted=deleted), 200
    finally:
        pool.putconn(conn)

if __name__ == "__main__":
    # local dev only; in EC2 use gunicorn
    app.run(host="0.0.0.0", port=5001)

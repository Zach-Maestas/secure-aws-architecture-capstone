from flask import Flask, request, jsonify
import os
import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv

# Load .env values
load_dotenv()

# Required environment variables
required_vars = ["DB_HOST", "DB_NAME", "DB_USER", "DB_PASSWORD"]
missing = [var for var in required_vars if not os.environ.get(var)]

if missing:
    print(f"⚠️ Missing DB env vars: {', '.join(missing)}. DB routes may fail.")

# Load env vars
DB_HOST = os.environ.get("DB_HOST")
DB_PORT = int(os.environ.get("DB_PORT", "5432"))
DB_NAME = os.environ.get("DB_NAME")
DB_USER = os.environ.get("DB_USER")
DB_PASSWORD = os.environ.get("DB_PASSWORD")

# DB connection helper
def get_db_connection():
    return psycopg2.connect(
        host=DB_HOST,
        port=DB_PORT,
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        connect_timeout=5,
        # sslmode="require"
    )

app = Flask(__name__)

@app.route("/health", methods=["GET"])
def health():
    return jsonify(status="ok"), 200

@app.route("/db/health", methods=["GET"])
def db_health():
    conn = get_db_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT 1;")
            cur.fetchone()
        return jsonify(db="ok"), 200
    except Exception as e:
        return jsonify(error=str(e)), 500
    finally:
        conn.close()

@app.route("/items", methods=["GET"])
def list_items():
    conn = get_db_connection()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT id, name, created_at FROM items ORDER BY id;")
            return jsonify(items=cur.fetchall()), 200
    except Exception as e:
        return jsonify(error=str(e)), 500
    finally:
        conn.close()

@app.route("/items", methods=["POST"])
def create_item():
    data = request.get_json(silent=True) or {}
    name = (data.get("name") or "").strip()
    if not name:
        return jsonify(error="name is required"), 400

    conn = get_db_connection()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute(
                "INSERT INTO items (name) VALUES (%s) RETURNING id, name, created_at;",
                (name,),
            )
            row = cur.fetchone()
            conn.commit()
            return jsonify(row), 201
    except Exception as e:
        return jsonify(error=str(e)), 500
    finally:
        conn.close()

@app.route("/items/<int:item_id>", methods=["GET"])
def get_item(item_id):
    conn = get_db_connection()
    try:
        with conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("SELECT id, name, created_at FROM items WHERE id=%s;", (item_id,))
            row = cur.fetchone()
            if not row:
                return jsonify(error="not found"), 404
            return jsonify(row), 200
    except Exception as e:
        return jsonify(error=str(e)), 500
    finally:
        conn.close()

@app.route("/items/<int:item_id>", methods=["DELETE"])
def delete_item(item_id):
    conn = get_db_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("DELETE FROM items WHERE id=%s;", (item_id,))
            deleted = cur.rowcount
            conn.commit()
            return jsonify(deleted=deleted), 200
    except Exception as e:
        return jsonify(error=str(e)), 500
    finally:
        conn.close()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

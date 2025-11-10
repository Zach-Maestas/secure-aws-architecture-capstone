from flask import Flask, request, jsonify
import os
import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv
import boto3
from botocore.exceptions import ClientError
import json
from flask_cors import CORS

app = Flask(__name__)
CORS(app, resources={r"/db/*": {"origins": "http://secure-capstone-frontend.s3-website-us-east-1.amazonaws.com"}})

def load_secret():
    secret_name = os.environ.get("SECRET_NAME", "capstone/secureaws/db-credentials")
    region_name = os.environ.get("AWS_REGION", "us-east-1")

    session = boto3.session.Session()
    client = session.client(service_name='secretsmanager', region_name=region_name)

    try:
        response = client.get_secret_value(SecretId=secret_name)
        secret = json.loads(response['SecretString'])

        # Map AWS secret keys to Flask env vars
        os.environ["DB_USER"] = secret["username"]
        os.environ["DB_PASSWORD"] = secret["password"]
        os.environ["DB_HOST"] = secret["host"]
        os.environ["DB_PORT"] = str(secret["port"])
        os.environ["DB_NAME"] = secret["db_name"]

    except ClientError as e:
        print(f"⚠️ Failed to load DB secret: {e}")

load_secret()

# Required environment variables
required_vars = ["DB_HOST", "DB_NAME", "DB_USER", "DB_PASSWORD"]
missing = [var for var in required_vars if not os.environ.get(var)]

if missing:
    print(f"⚠️ Missing DB env vars: {', '.join(missing)}. DB routes may fail.")

# DB connection helper
def get_db_connection():
    return psycopg2.connect(
        host=os.environ.get("DB_HOST"),
        port=int(os.environ.get("DB_PORT", "5432")),
        dbname=os.environ.get("DB_NAME"),
        user=os.environ.get("DB_USER"),
        password=os.environ.get("DB_PASSWORD"),
        connect_timeout=5,
        sslmode="require"
    )

@app.route("/", methods=["GET"])
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

@app.route("/db/items", methods=["GET"])
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

@app.route("/db/items", methods=["POST"])
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

@app.route("/db/items/<int:item_id>", methods=["GET"])
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

@app.route("/db/items/<int:item_id>", methods=["DELETE"])
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


# Enable CORS for specific frontend origin
@app.after_request
def after_request(response):
    response.headers.add("Access-Control-Allow-Origin", "http://secure-capstone-frontend.s3-website-us-east-1.amazonaws.com")
    response.headers.add("Access-Control-Allow-Headers", "Content-Type,Authorization")
    response.headers.add("Access-Control-Allow-Methods", "GET,PUT,POST,DELETE,OPTIONS")
    return response

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

import json
import os
from datetime import datetime

import pytz
import redis
from flask import Flask, jsonify, request
from werkzeug.exceptions import BadRequest

app = Flask(__name__)


def init_redis():
    redis_host = os.getenv("REDIS_HOST", "localhost")
    redis_port = os.getenv("REDIS_PORT", "6379")
    app.redis_client = redis.Redis(host=redis_host, port=redis_port, db=0)


@app.route("/v1/batch", methods=["GET"])
def get_batches():
    batch = []
    for key in app.redis_client.scan_iter(f"batch:*"):
        batch.append(key.decode('utf-8'))
    return jsonify(batch), 200


@app.route("/v1/batch/<batch_name>", methods=["GET"])
def get_batch(batch_name):
    batch = []
    for key in app.redis_client.sscan_iter(f"batch:{batch_name}"):
        batch.append(json.loads(app.redis_client.get(key.decode('utf-8'))))

    if len(batch) is 0:
        return api_error("Batch does not exist", 404)
    return jsonify(batch), 200


@app.route("/v1/state/<dd_filename>", methods=["GET"])
def get_state_record(dd_filename):
    state_record = app.redis_client.get(dd_filename)
    if state_record is None:
        return api_error("State record does not exist", 404)
    return json.loads(state_record)


@app.route("/v1/state/<dd_filename>", methods=["POST"])
def create_state_record(dd_filename):
    state_request = request.json
    state = state_request.get("state")
    batch = state_request.get("batch")
    if state is None or batch is None:
        return api_error("Request did not include 'state' or 'batch'")
    if app.redis_client.get(dd_filename) is not None:
        return api_error("Resource already exists", 409)
    state_record = {
        "state": state,
        "updated_at": updated_at(),
        "dd_filename": dd_filename,
        "batch": batch,
    }
    app.redis_client.set(dd_filename, json.dumps(state_record))
    app.redis_client.sadd(f"batch:{batch}", dd_filename)
    return state_record


@app.route("/v1/state/<dd_filename>", methods=["PATCH"])
def update_state_record(dd_filename):
    state_request = request.json
    state = state_request.get("state")
    if state is None:
        return api_error("Request did not include 'state'")

    state_record = app.redis_client.get(dd_filename)
    if state_record is None:
        return api_error("State record does not exist", 404)

    state_record = json.loads(state_record)
    if state_record["state"] == state:
        return api_error("State is unchanged", 400)

    state_record["updated_at"] = updated_at()
    state_record["state"] = state
    app.redis_client.set(dd_filename, json.dumps(state_record))
    return state_record


@app.errorhandler(BadRequest)
def handle_bad_request(e):
    return api_error("Invalid post request")


def api_error(message, status_code=400):
    return jsonify({"error": message}), status_code


def updated_at():
    return datetime.now(pytz.utc).replace(microsecond=0).isoformat()


if __name__ == "__main__":
    init_redis()
    app.run(host="0.0.0.0", port=5008)

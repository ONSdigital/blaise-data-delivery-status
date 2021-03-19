import json
import os

import redis
from flask import Flask, request

app = Flask(__name__)


def init_redis():
    redis_host = os.getenv("REDIS_HOST", "localhost")
    redis_port = os.getenv("REDIS_PORT", "6379")
    app.redis_client = redis.Redis(host=redis_host, port=redis_port, db=0)


@app.route("/v1/state/<dd_filename>", methods=["POST"])
def create_state_record(dd_filename):
    state_request = request.json
    state = state_request.get("state")
    batch = state_request.get("batch")
    if state is None or batch is None:
        return 400, "Request did not include 'state' or 'batch'"
    state_record = {"state": state}
    app.redis_client.set(dd_filename, json.dumps(state_record))
    app.redis_client.sadd(f"batch:{batch}", dd_filename)
    return state_record

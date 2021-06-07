import os
from flask.wrappers import Response

import redis
from flask import Flask, jsonify
from werkzeug.exceptions import BadRequest

from app.batch import batch
from app.state import state
from app.utils import api_error

app = Flask(__name__)

app.register_blueprint(batch)
app.register_blueprint(state)


def init_redis(app):
    redis_host = os.getenv("REDIS_HOST", "localhost")
    redis_port = os.getenv("REDIS_PORT", "6379")
    app.redis_client = redis.Redis(host=redis_host, port=redis_port, db=0)


@app.route("/_ah/stop")
def instance_shutdown():
    print("Instance shutdown request closing redis_client connection")
    app.redis_client.close()
    return "", 200


@app.route("/data-delivery-status/<version>/health")
def health_check(version):
    print(f"Checking {version} health by checking redis connectivity")
    try:
        app.redis_client.ping()
        response = {"healthy": True}
        return jsonify(response)
    except:
        response = {"healthy": False}
        return jsonify(response)

@app.errorhandler(BadRequest)
def handle_bad_request(e):
    return api_error("Invalid post request")

from flask import Flask, jsonify
from google.cloud import datastore
from werkzeug.exceptions import BadRequest

from app.batch import batch
from app.state import state
from app.utils import api_error

app = Flask(__name__)

app.register_blueprint(batch)
app.register_blueprint(state)


def init_datastore(app):
    app.datastore_client = datastore.Client()


@app.route("/dds/<version>/health")
def health_check(version):
    print(f"Checking {version} health by checking connectivity")
    try:
        response = {"healthy": True}
        return jsonify(response)
    except Exception:
        response = {"healthy": False}
        return jsonify(response)


@app.errorhandler(BadRequest)
def handle_bad_request(e):
    return api_error("Invalid post request")

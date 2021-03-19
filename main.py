import json
from datetime import datetime

import redis
from flask import Flask, abort, request

app = Flask(__name__)

REDIS_HOST = "localhost"
REDIS_PORT = 55001

super_generic_database = redis.Redis(host=REDIS_HOST, port=REDIS_PORT)


@app.route("/state/<dd_filename>", methods=["POST"])
def home(dd_filename):
    state = request.form["state"]
    created = request.form.get("created", None)

    data = {
        "state": state,
        "step": "",
        "run_timestamp": created,
        "updated_timestamp": str(datetime.now()),
    }

    super_generic_database.set(dd_filename, json.dumps(data))
    return "saved", 200


@app.route("/state/<dd_filename>", methods=["PATCH"])
def update(dd_filename):
    state = request.form["state"]

    dd_status = json.loads(super_generic_database.get(dd_filename))
    if dd_status is None:
        abort(404)

    dd_status['state'] = state
    dd_status['updated_timestamp'] = str(datetime.now())

    super_generic_database.set(dd_filename, json.dumps(dd_status))
    return "update", 200


@app.route("/state/<instrument_name>", methods=["GET"])
def get(instrument_name):
    name = super_generic_database.get(instrument_name)
    if name is None:
        abort(404)
    return name


# Press the green button in the gutter to run the script.
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5007)

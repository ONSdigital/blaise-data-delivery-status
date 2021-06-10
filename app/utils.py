from datetime import datetime

import pytz
from flask import jsonify

from client.blaise_dds import STATES


def api_error(message, status_code=400):
    return jsonify({"error": message}), status_code


def updated_at():
    return datetime.now(pytz.utc).replace(microsecond=0).isoformat()


def state_error(state):
    valid_states = ", ".join(STATES.keys())
    return api_error(f"State '{state}' is invalid, valid states are [{valid_states}]")

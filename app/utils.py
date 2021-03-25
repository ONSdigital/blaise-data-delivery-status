from datetime import datetime

import pytz
from flask import jsonify

STATES = {
    "inactive": "The data delivery instrument has no active survey days, we will note geneate a data delivery file, we should never alert",  # noqa: E501
    "started": "The data delivery process has found an instrument with active survey days",  # noqa: E501
    "generated": "The data delivery process has generated the required files",
    "in_staging": "The data delivery files have been copied to the staging bucket",
    "encrypted": "The data delivery files have been encrypted and are ready for NiFi",
    "in_nifi_bucket": "The data delivery files are in the NiFi bucket",
    "nifi_notified": "NiFi has been notified that we have files to ingest",
    "in_arc": "NiFi has copied the files to ARC (on prem) and sent a receipt",
    "errored": "An error has occured processing the file (error receipt from NiFi for example)",  # noqa: E501
}


def api_error(message, status_code=400):
    return jsonify({"error": message}), status_code


def updated_at():
    return datetime.now(pytz.utc).replace(microsecond=0).isoformat()


def state_is_valid(state):
    return state in STATES.keys()


def state_error(state):
    valid_states = ", ".join(STATES.keys())
    return api_error(f"State '{state}' is invalid, valid states are [{valid_states}]")

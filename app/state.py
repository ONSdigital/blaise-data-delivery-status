import json

from flask import Blueprint, current_app, request

from app.utils import api_error, updated_at

state = Blueprint("state", __name__, url_prefix="/v1/state")


@state.route("/<dd_filename>", methods=["GET"])
def get_state_record(dd_filename):
    state_record = current_app.redis_client.get(dd_filename)
    if state_record is None:
        return api_error("State record does not exist", 404)
    return json.loads(state_record)


@state.route("/<dd_filename>", methods=["POST"])
def create_state_record(dd_filename):
    state_request = request.json
    state = state_request.get("state")
    batch = state_request.get("batch")
    error_info = state_request.get("error_info")
    if state is None or batch is None:
        return api_error("Request did not include 'state' or 'batch'")
    if state != "errored" and error_info is not None:
        return api_error("You can only provide 'error_info' if the state is 'errored'")
    if current_app.redis_client.get(dd_filename) is not None:
        return api_error("Resource already exists", 409)
    state_record = {
        "state": state,
        "updated_at": updated_at(),
        "dd_filename": dd_filename,
        "batch": batch,
    }
    if error_info:
        state_record["error_info"] = error_info
    current_app.redis_client.set(dd_filename, json.dumps(state_record))
    current_app.redis_client.sadd(f"batch:{batch}", dd_filename)
    return state_record, 201


@state.route("/<dd_filename>", methods=["PATCH"])
def update_state_record(dd_filename):
    state_request = request.json
    state = state_request.get("state")
    error_info = state_request.get("error_info")
    if state is None:
        return api_error("Request did not include 'state'")
    if state != "errored" and error_info is not None:
        return api_error("You can only provide 'error_info' if the state is 'errored'")

    state_record = current_app.redis_client.get(dd_filename)
    if state_record is None:
        return api_error("State record does not exist", 404)

    state_record = json.loads(state_record)
    if state_record["state"] == state:
        return api_error("State is unchanged", 400)

    state_record["updated_at"] = updated_at()
    state_record["state"] = state
    if error_info:
        state_record["error_info"] = error_info
    current_app.redis_client.set(dd_filename, json.dumps(state_record))
    return state_record

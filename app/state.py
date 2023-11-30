import json

from flask import Blueprint, current_app, request
from google.cloud import datastore

from app.utils import api_error, state_error, updated_at, get_datastore_entity
from client.blaise_dds import DATASTORE_KIND, STATES, state_is_valid

state = Blueprint("state", __name__, url_prefix="/v1/state")

@state.route("/<dd_filename>", methods=["GET"])
def get_state_record(dd_filename):
    state_record = get_datastore_entity(current_app.datastore_client, dd_filename)
    if state_record is None:
        return api_error("State record does not exist", 404)
    return state_record


@state.route("/<dd_filename>", methods=["POST"])
def create_state_record(dd_filename):
    state_request = request.json
    state = state_request.get("state")
    batch = state_request.get("batch")
    error_info = state_request.get("error_info")
    
    if state is None or batch is None:
        return api_error("Request did not include 'state' or 'batch'")
    if not state_is_valid(state):
        return state_error(state)
    if state != "errored" and error_info is not None:
        return api_error("You can only provide 'error_info' if the state is 'errored'")
    if get_datastore_entity(current_app.datastore_client, dd_filename) is not None:
        return api_error("Resource already exists", 409)
    
    state_record = {
        "state": state,
        "updated_at": updated_at(),
        "dd_filename": dd_filename,
        "batch": batch,
        "alerted": False,
    }
    if error_info:
        state_record["error_info"] = error_info
    
    record_entity = datastore.Entity(
        current_app.datastore_client.key(DATASTORE_KIND, dd_filename)
    )
    for key, value in state_record.items():
        record_entity[key] = value
    current_app.datastore_client.put(record_entity)

    return state_record, 201


@state.route("/<dd_filename>", methods=["PATCH"])
def update_state_record(dd_filename):
    state_request = request.json
    state = state_request.get("state")
    error_info = state_request.get("error_info")
    if state is None:
        return api_error("Request did not include 'state'")

    if not state_is_valid(state):
        return state_error(state)

    if state != "errored" and error_info is not None:
        return api_error("You can only provide 'error_info' if the state is 'errored'")

    state_record = get_datastore_entity(current_app.datastore_client, dd_filename)
    if state_record is None:
        return api_error("State record does not exist", 404)

    if state_record["state"] == state:
        return api_error("State is unchanged", 400)

    state_record["updated_at"] = updated_at()
    state_record["state"] = state
    state_record["alerted"] = False
    if error_info:
        state_record["error_info"] = error_info
    current_app.datastore_client.put(state_record)
    
    return state_record


@state.route("/<dd_filename>/alerted", methods=["PATCH"])
def set_alerted(dd_filename):
    state_request = request.json
    alerted = state_request.get("alerted")
    if alerted is None:
        return api_error("Request did not include 'alerted'")

    if type(alerted) is not bool:
        return api_error("Alerted must be a boolean")

    state_record = get_datastore_entity(current_app.datastore_client, dd_filename)
    if state_record is None:
        return api_error("State record does not exist", 404)

    state_record["alerted"] = alerted
    current_app.datastore_client.put(state_record)

    return state_record


@state.route("/descriptions", methods=["GET"])
def get_state_descriptions():
    return STATES

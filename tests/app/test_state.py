import pytest
from flask import Flask
from unittest.mock import MagicMock

from app.state import state
from app.models import STATES


@pytest.fixture
def client():
    app = Flask(__name__)
    app.register_blueprint(state)
    app.datastore_client = MagicMock()
    return app.test_client()


def test_get_state_record_not_found(client):
    client.application.datastore_client.get.return_value = None
    resp = client.get("/v1/state/test.json")
    assert resp.status_code == 404


def test_create_state_record_success(client):
    client.application.datastore_client.get.return_value = None
    client.application.datastore_client.put.return_value = None

    valid_state = list(STATES.keys())[0]
    data = {"state": valid_state, "batch": "batch1"}
    resp = client.post("/v1/state/test.json", json=data)

    assert resp.status_code == 201
    body = resp.get_json()
    assert body["state"] == valid_state
    assert body["batch"] == "batch1"


def test_create_state_record_conflict(client):
    client.application.datastore_client.get.return_value = {"state": "received"}
    valid_state = list(STATES.keys())[0]
    data = {"state": valid_state, "batch": "batch1"}
    resp = client.post("/v1/state/test.json", json=data)
    assert resp.status_code == 409


def test_update_state_record_success(client):
    valid_states = list(STATES.keys())
    current_state, new_state = valid_states[0], valid_states[1]

    existing = {"state": current_state}
    client.application.datastore_client.get.return_value = existing

    data = {"state": new_state}
    resp = client.patch("/v1/state/test.json", json=data)

    assert resp.status_code == 200
    body = resp.get_json()
    assert body["state"] == new_state


def test_set_alerted_success(client):
    existing = {"state": "received", "alerted": False}
    client.application.datastore_client.get.return_value = existing

    data = {"alerted": True}
    resp = client.patch("/v1/state/test.json/alerted", json=data)

    assert resp.status_code == 200
    body = resp.get_json()
    assert body["alerted"] is True


def test_get_state_descriptions(client):
    resp = client.get("/v1/state/descriptions")
    assert resp.status_code == 200
    body = resp.get_json()
    assert body == STATES

import pytest
from flask import Flask
from unittest.mock import MagicMock

from app.batch import batch


@pytest.fixture
def client():
    app = Flask(__name__)
    app.register_blueprint(batch)
    app.datastore_client = MagicMock()
    return app.test_client()


def test_get_batches_success(client):
    mock_query = MagicMock()
    mock_query.fetch.return_value = [
        {"batch": "batch1"},
        {"batch": "batch2"},
        {"batch": "batch1"},
    ]
    client.application.datastore_client.query.return_value = mock_query

    resp = client.get("/v1/batch")
    assert resp.status_code == 200
    body = resp.get_json()
    assert body == ["batch1", "batch2"]


def test_get_batch_success(client):
    mock_query = MagicMock()
    mock_query.fetch.return_value = [{"batch": "batch1", "state": "received"}]
    client.application.datastore_client.query.return_value = mock_query

    resp = client.get("/v1/batch/batch1")
    assert resp.status_code == 200
    body = resp.get_json()
    assert isinstance(body, list)
    assert body[0]["batch"] == "batch1"


def test_get_batch_not_found(client):
    mock_query = MagicMock()
    mock_query.fetch.return_value = []
    client.application.datastore_client.query.return_value = mock_query

    resp = client.get("/v1/batch/unknown")
    assert resp.status_code == 404
    body = resp.get_json()
    assert "error" in body

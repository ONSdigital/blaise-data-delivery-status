from unittest.mock import MagicMock

import pytest
from flask import Flask

from app import utils
from app.models import DATASTORE_KIND, STATES


def test_get_datastore_entity_success():
    mock_client = MagicMock()
    mock_key = MagicMock()
    mock_entity = {"dd_filename": "test.json"}

    mock_client.key.return_value = mock_key
    mock_client.get.return_value = mock_entity

    result = utils.get_datastore_entity(mock_client, "test.json")

    assert result == mock_entity
    mock_client.key.assert_called_once_with(DATASTORE_KIND, "test.json")
    mock_client.get.assert_called_once_with(key=mock_key)


def test_get_datastore_entity_raises_value_error():
    mock_client = MagicMock()
    mock_client.key.side_effect = ValueError("boom")
    with pytest.raises(ValueError):
        utils.get_datastore_entity(mock_client, "bad.json")


def test_api_error_and_state_error():
    app = Flask(__name__)
    with app.app_context():
        resp, code = utils.api_error("something went wrong")
        assert code == 400
        assert resp.get_json() == {"error": "something went wrong"}

        resp, code = utils.api_error("not found", 404)
        assert code == 404
        assert resp.get_json() == {"error": "not found"}

        resp, code = utils.state_error("not_a_state")
        assert code == 400
        error_msg = resp.get_json()["error"]
        assert "not_a_state" in error_msg
        for state in STATES.keys():
            assert state in error_msg


def test_updated_at_format():
    ts = utils.updated_at()
    assert "T" in ts
    assert ts.endswith("+00:00")
    assert "." not in ts

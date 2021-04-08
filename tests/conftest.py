import pytest

from client.blaise_dds import Client, Config


@pytest.fixture
def client():
    return Client(Config(URL="http://localhost"))

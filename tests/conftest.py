import pytest

from client import Client, Config


@pytest.fixture
def client():
    return Client(Config(URL="http://localhost"))

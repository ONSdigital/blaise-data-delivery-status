import os
from google.cloud import datastore
from behave import fixture, use_fixture

from app.app import app
from client.blaise_dds import DATASTORE_KIND
import os


@fixture
def flaskr_client(context, *args, **kwargs):
    # TODO: Are these even used?
    # os.environ["DATASTORE_PROJECT_ID"] = "test-project"
    # os.environ["DATASTORE_HOST"] = "http://localhost:8081"
    # os.environ["DATASTORE_EMULATOR_HOST"] = "localhost:8081"
    # os.environ["DATASTORE_EMULATOR_HOST_PATH"] = "localhost:8081/datastore"
    
    app.testing = True
    context.client = app.test_client()

    app.datastore_client = datastore.Client()
    
    context.datastore_client = app.datastore_client
    # TODO: Does it even interact with the local Datastore?
    # key = context.datastore_client.key(
    #         DATASTORE_KIND,
    #         "key"
    # )
    # print("DOES IT SEND??", context.datastore_client.get(key=key))

    yield context.client


def before_scenario(context, _scenario):
    use_fixture(flaskr_client, context)


def after_scenario(context, _scenario):
    # if context.freezer:
    #     context.freezer.stop()
    return 'hello'

from google.cloud import datastore
from behave import fixture, use_fixture
from client.blaise_dds import DATASTORE_KIND

from app.app import app


@fixture
def flaskr_client(context, *args, **kwargs):
    app.testing = True
    context.client = app.test_client()
    app.datastore_client = datastore.Client()
    context.datastore_client = app.datastore_client

    yield context.client


def before_scenario(context, _scenario):
    use_fixture(flaskr_client, context)


def after_scenario(context, _scenario):
    query = context.datastore_client.query(kind=DATASTORE_KIND)
    query_results = list(query.fetch())
    context.datastore_client.delete_multi(query_results)

    if context.freezer:
        context.freezer.stop()
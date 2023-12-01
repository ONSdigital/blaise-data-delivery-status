import fakeredis
from google.cloud import datastore
from behave import fixture, use_fixture

from app.app import app


@fixture
def flaskr_client(context, *args, **kwargs):
    app.datastore_client = datastore.Client()
    context.datastore_client = app.datastore_client
    app.testing = True
    context.client = app.test_client()
    yield context.client


def before_scenario(context, _scenario):
    use_fixture(flaskr_client, context)


def after_secerio(context, _scenario):
    if context.freezer:
        context.freezer.stop()

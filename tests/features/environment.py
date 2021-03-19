import fakeredis
from behave import fixture, use_fixture

from app.app import app


@fixture
def flaskr_client(context, *args, **kwargs):
    app.redis_client = fakeredis.FakeStrictRedis()
    context.redis_client = app.redis_client
    app.testing = True
    context.client = app.test_client()
    yield context.client


def before_scenario(context, _scenario):
    use_fixture(flaskr_client, context)


def after_secerio(context, _scenario):
    if context.freezer:
        context.freezer.stop()

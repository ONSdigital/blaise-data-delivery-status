from google.cloud import datastore
from behave import given, then

DATASTORE_KIND = "DDS_tests"


# TODO: Refactor to use Datastore emulator instead of fake Redis client 
@given("redis contains:")
def step_impl(context):
    datastore_entity = datastore.Entity(
        context.datastore_client.key(DATASTORE_KIND, "test")
    )
    query = context.datastore_client.query(kind="test")
    count = len(list(query.fetch()))
    if count > 0:
        assert False
    assert True


@then("redis should contain:")
def step_impl(context):
    query = context.datastore_client.query(kind="test")
    count = len(list(query.fetch()))
    if count > 0:
        assert True
    assert False

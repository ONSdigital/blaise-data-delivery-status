from google.cloud import datastore
from behave import given, then

DATASTORE_KIND = "DDS_tests"

# TODO: Refactor to use Datastore emulator instead of fake Redis client 
@given("redis contains")
def step_impl(context):
    datastore_entity = datastore.Entity(
        context.datastore_client.key(DATASTORE_KIND, "test")
    ) 
    for row in context.table:
        datastore_entity[row["key"]] = row["value"]


@given('the redis set "{set}" contains')
def step_impl(context, set):        
    for row in context.table:
        context.datastore_client.get(context.datastore_client.key(DATASTORE_KIND, row["key"])) 
        if (datastore_entity[row["key"]] == row["key"]):
            datastore_entity[row["key"]] = row["key"]


@then("redis should contain")
def step_impl(context):
    for row in context.table:
        value = context.redis_client.get(row["key"])
        assert (
            value.decode("utf-8") == row["value"]
        ), f"Value should have been: '{row['value']}' but was '{value.decode('utf-8')}'"


@then('the set "{set}" should contain')
def step_impl(context, set):
    expected_members = [row["key"] for row in context.table]
    members = context.redis_client.smembers(f"batch:{set}")
    members = [member.decode("utf-8") for member in members]
    assert (
        members == expected_members
    ), f"Members '{members}' did not equal expected members '{expected_members}'"

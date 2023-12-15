import json

from google.cloud import datastore
from behave import given, then
from client.blaise_dds import DATASTORE_KIND

@given("Datastore contains")
def step_impl(context):
    data = json.loads(context.text)
    if len(data) == 0: return None

    for item in data:
        record_entity = datastore.Entity(
            context.datastore_client.key(DATASTORE_KIND, item["dd_filename"])
        )
        record_entity.update(item)
        context.datastore_client.put(record_entity)


@then("Datastore should contain")
def step_impl(context):
    # arrange
    expected = json.loads(context.text)

    client = context.datastore_client
    filters = [("updated_at", "=", expected["updated_at"])]
    query = client.query(kind=DATASTORE_KIND, filters=filters)
    query_iter = query.fetch()

    # act
    result = dict(list(query_iter)[0])

    # assert
    assert result == expected
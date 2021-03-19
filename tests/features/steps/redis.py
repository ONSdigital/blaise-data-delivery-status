from behave import given, then


@given("redis contains")
def step_impl(context):
    for row in context.table:
        context.redis_client.set(row["key"], row["value"])


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

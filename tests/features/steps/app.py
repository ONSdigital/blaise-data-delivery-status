import json

from behave import given, then, when
from freezegun import freeze_time


@when('I POST to "{path}" with the payload')
def step_impl(context, path):
    response = context.client.post(
        path, data=context.text, content_type="application/json"
    )
    context.response = response.get_json()


@then("the response should be")
def step_impl(context):
    assert context.response == json.loads(
        context.text
    ), f"Response {context.response} did not match expected value: {context.text}"


@given('the current time is "{time}"')
def step_impl(context, time):
    context.freezer = freeze_time(time)
    context.freezer.start()

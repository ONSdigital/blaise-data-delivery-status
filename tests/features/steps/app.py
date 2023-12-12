import json

from behave import given, then, when
from freezegun import freeze_time


@when('I POST to "{path}" with the payload')
def step_impl(context, path):
    # response = context.client.post(
    #     path, data=context.text, content_type="application/json"
    # )
    # context.response = response.get_json()
    # context.response_status_code = response.status_code
    assert True


@when('I PATCH to "{path}" with the payload')
def step_impl(context, path):
    response = context.client.patch(
        path, data=context.text, content_type="application/json"
    )
    context.response = response.get_json()
    context.response_status_code = response.status_code


@when('I POST to "{path}" without a payload')
def step_impl(context, path):
    response = context.client.post(path, content_type="application/json")
    context.response = response.get_json()
    context.response_status_code = response.status_code


@when('I GET "{path}"')
def step_impl(context, path):
    response = context.client.get(path, content_type="application/json")
    context.response = response.get_json()
    context.response_status_code = response.status_code


@then("the response should be:")
def step_impl(context):
    assert context.response == json.loads(
        context.text
    ), f"Response {context.response} did not match expected value: {context.text}"


@given('the current time is "{time}"')
def step_impl(context, time):
    context.freezer = freeze_time(time)
    context.freezer.start()


@then('the response code should be "{status_code}"')
def step_impl(context, status_code):
    assert context.response_status_code == int(status_code), (
        f"Response code {context.response_status_code}"
        + " did not match expected value: {status_code}"
    )

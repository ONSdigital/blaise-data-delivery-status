import json

from behave import given, then, when
from freezegun import freeze_time


@given('the current time is set')
def step_impl(context):
    context.freezer = freeze_time(context.time)
    context.freezer.start()


@when('I POST to "{path}" with the payload')
def step_impl(context, path):
    response = context.client.post(
        path, data=context.text, content_type="application/json"
    )
    context.response = response.get_json()
    context.response_status_code = response.status_code
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


@then('the response should be')
def step_impl(context):
    context.response["updated_at"] = context.time

    context_entity = json.loads(context.text)
    context_entity["updated_at"] = context.time

    assert context.response == context_entity, f"Response {context.response} did not match expected value: {context.text}"

@then('the response list should be')
def step_impl(context):
    context_entities_list = json.loads(context.text)
    for i in range(0, len(context_entities_list)):
        context_entities_list[i]["updated_at"] = context.time

    assert context.response == context_entities_list, f"Response {context.response} did not match expected value: {context.text}"

@then('the batch list should be')
def step_impl(context):
    context_list = json.loads(context.text)

    assert context.response == context_list, f"Response {context.response} did not match expected value: {context.text}"

@then('the response code should be "{status_code}"')
def step_impl(context, status_code):
    assert context.response_status_code == int(status_code), (
            f"Response code {context.response_status_code}"
            + f" did not match expected value: {status_code}"
    )
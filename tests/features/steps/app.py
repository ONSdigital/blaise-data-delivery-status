from datetime import datetime
import json

import pytz
from behave import given, then, when
from freezegun import freeze_time


@given('the current time is set')
def step_impl(context):
    print("STEP 2: ", context.time)
    context.freezer = freeze_time(context.time)
    context.freezer.start()
    print("STEP 2: ", context.time)
    print("STEP 2: FROME DATETIME ", datetime.now(pytz.utc).replace(microsecond=0).isoformat())


@when('I POST to "{path}" with the payload')
def step_impl(context, path):
    response = context.client.post(
        path, data=context.text, content_type="application/json"
    )
    print("STEP 3: ", context.time)
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
    print("STEP 5: RESPONSE SHOULD BE", context.time)
    context.response["updated_at"] = context.time

    context_entity = json.loads(context.text)
    context_entity["updated_at"] = context.time

    assert context.response == context_entity, f"Response {context.response} did not match expected value: {context.text}"

# @then('the response code should be {status_code}')
# def step_impl(context, status_code):
#     assert context.response_status_code == int(status_code), (
#             f"Response code {context.response_status_code}"
#             + " did not match expected value: {status_code}"
#     )

@then('the response code should be "{status_code}"')
def step_impl(context, status_code):
    print("STEP 4: RESPONSE CODE STEP", context.time)
    assert context.response_status_code == int(status_code), (
            f"Response code {context.response_status_code}"
            + f" did not match expected value: {status_code}"
    )
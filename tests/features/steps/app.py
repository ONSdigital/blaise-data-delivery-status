from behave import when, then


@when(u'I POST to "{path}" with the payload')
def step_impl(context, path):
    response = context.client.post(path, data=context.text, content_type="application/json")
    context.response = response.data.decode("utf-8")


@then('the response should contain')
def step_impl(context):
    assert context.response in context.text, f"Response {context.response} did not match expected value: {context.text}"

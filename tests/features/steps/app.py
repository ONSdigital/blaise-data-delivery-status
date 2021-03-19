from behave import when


@when(u'I POST to "{path}" with the payload')
def step_impl(context, path):
    context.client.post(path, data=context.text, content_type="application/json")

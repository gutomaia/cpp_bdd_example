from behave import *


@given(u'an calculator')
def step_impl(context):
    import example
    context.calculator = example

@when(u'input {a} plus {b}')
def step_impl(context, a, b):
    x, y = int(a), int(b)
    context.result = context.calculator.add(x, y)

@then(u'get 4')
def step_impl(context):
    assert context.result == 4

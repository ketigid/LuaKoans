function test_assert()
  assert_true(true) -- this should be true. This is how you write comments in Lua
end

function test_assert_with_message()
  assert_true(true, 'This should be true')
end

function test_assert_expression()
  local expected_value = 2
  local actual_value = 1 + 1
  assert_true(expected_value == actual_value)
end

function test_assert_equals()
  local expected_value = 2
  local actual_value = 1 + 1
  assert_equal(expected_value, actual_value)
end

function test_assert_fill_in_values()
  assert_equal(1 + 1, 2)
end

function test_assert_not()
  assert_not(false, 'This should be false')
end

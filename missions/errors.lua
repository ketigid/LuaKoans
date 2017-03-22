function test_basic_error_and_pcall()
  local value = 1
  local function problematic_func()
    value = 2
    error('this is an error message')
    value = 3
  end
  local status, message = pcall(problematic_func)

  assert_equal(2, value)
  assert_equal(false, status)
  -- the message includes file info, so it'll vary depending on the platform
  assert_equal('errors.lua:5: this is an error message', message)
end

function test_pcall_returns_true_followed_by_return_values_when_no_errors_are_raised()
  local function noproblemo()
    return 'foo', 'bar'
  end
  local status, x, y = pcall(noproblemo)

  assert_equal(true, status)
  assert_equal('foo', x)
  assert_equal('bar', y)
end

function test_pcall_can_pass_parameters_to_invoked_function()
  local function sum(x,y)
    return x+y
  end
  local status, result = pcall(sum, 10, 20)

  assert_equal(true, status)
  assert_equal(30, result)
end

function test_pcall_works_ok_on_anonymous_functions()
  local status, message = pcall(function() error('hi!') end)
  assert_equal(false, status)
  assert_equal('errors.lua:38: hi!', message)
end

function test_pcall_works_ok_on_error_itself()
  local status, message = pcall(error, 'Hello')
  assert_equal(false, status)
  assert_equal('Hello', message)
end

function test_error_removes_file_info_if_second_param_is_0()
  local _, message = pcall(error, 'World', 0)
  assert_equal('World', message)
end


function test_error_returning_non_strings_converts_to_string_but_suppresses_file_info()
  local tbl = {text = "an error inside a table"}
  local _, message = pcall(error, tbl)
  assert_equal('table', type(message))
  assert_equal('an error inside a table', message.text)
  -- You can return ANY Lua value as an error: strings, numbers, but also tables, functions, etc.
end

function test_assert_is_defined_by_lua()
  local status, message = pcall(function() assert(false, "This is an error") end)
  assert_equal(false, status)
  assert_equal('errors.lua:64: This is an error', message)
  -- exercise left out to the reader: figure out how assert might be implemented
end

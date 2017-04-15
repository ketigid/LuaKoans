-- The following two lines define two functions which will be used on this exercise.
-- For now you can just ignore them
local function lua_greater_or_equal_5_3() return table.move end
local function lua_greater_or_equal_5_2() return _G.rawlen end

function test_coroutine_is_of_type_table()
  assert_equal('table', type(coroutine))
end

function test_table_coroutine_contains_six_or_seven_elements()
  local counter = 0
  for key in pairs(coroutine) do
    counter = counter + 1
  end
  if lua_greater_or_equal_5_3() then
    -- if you are on Lua >=5.3
    assert_equal(7, counter)
  else
    -- if you are on Lua <=5.2
    assert_equal(6, counter)
  end
end
-- Table elements:
-- create     resume    status
-- running    wrap      yield
-- Lua 5.3:   isyieldable

function test_all_elements_of_table_coroutine_are_of_type_function()
  for key, value in pairs(coroutine) do
    assert_equal('function', type(value))
  end
end

function test_created_coroutine_is_of_type_thread()
  local corothread = coroutine.create(
    function()
    end
  )
  assert_equal('thread', type(corothread))
end

function test_status_of_created_coroutine_is_suspended()
  local corothread = coroutine.create(
    function()
    end
  )
  assert_equal('suspended', coroutine.status(corothread))
end

function test_created_coroutine_can_be_successfully_resumed()
  local corothread = coroutine.create(
    function()
    end
  )
  assert_equal(true, coroutine.resume(corothread))
end

function test_coroutine_without_yield_is_dead_after_resume()
  local corothread = coroutine.create(
    function()
    end
  )
  coroutine.resume(corothread)
  assert_equal('dead', coroutine.status(corothread))
end

function test_coroutine_with_yield_is_suspended_after_first_resume()
  local corothread = coroutine.create(
    function()
      coroutine.yield()
    end
  )
  coroutine.resume(corothread)
  assert_equal('suspended', coroutine.status(corothread))
end

function test_coroutine_with_yield_is_dead_after_second_resume()
  local corothread = coroutine.create(
    function()
      coroutine.yield()
    end
  )
  coroutine.resume(corothread)
  coroutine.resume(corothread)
  assert_equal('dead', coroutine.status(corothread))
end

function test_resuming_dead_coroutine_results_in_error()
  local corothread = coroutine.create(
    function()
    end
  )
  local errorfree1, _ = coroutine.resume(corothread)
  local errorfree2, errdescr = coroutine.resume(corothread)
  assert_equal(true, errorfree1)
  assert_equal(false, errorfree2)
  assert_equal('cannot resume dead coroutine', errdescr)
end

function test_status_of_coroutine_that_resumed_another_coroutine_is_normal()
  local corothread1, corothread2, statusthread1
  corothread1 = coroutine.create(
    function()
      coroutine.resume(corothread2)
    end
  )
  corothread2 = coroutine.create(
    function()
      statusthread1 = coroutine.status(corothread1)
    end
  )
  coroutine.resume(corothread1)
  assert_equal('normal', statusthread1)
end

function test_coroutine_running_returns_current_coroutine()
  local val1, val2, val3
  local cor = coroutine.create(
    function()
      val3 = coroutine.running()
      coroutine.yield()
    end
  )
  val1 = coroutine.running()
  coroutine.resume(cor)
  val2 = coroutine.running()

  -- The behavior of coroutine.running has changed
  -- There is an "always-running main coroutine" in Lua >= 5.2
  -- Plus, coroutine.running returns a second parameter (see below)
  if lua_greater_or_equal_5_2() then
    assert_equal('thread', type(val1))
    assert_equal('thread', type(val2))
    assert_equal(true,  val1 == val2)
    assert_equal(false, val1 == val3)
    assert_equal(true, val3 == cor)
  else
  -- In Lua 5.1 and LuaJIT, there is no "main coroutine", to coroutine.running can return nil
    assert_equal(__, type(val1))
    assert_equal(__, type(val2))
    assert_equal(__, val1 == val2)
    assert_equal(__, val3 == cor)
  end
end

-- The following 2 tests only apply to Lua >= 5.2, because coroutine.running returns a second value there
if lua_greater_or_equal_5_2() then

  function test_coroutine_running_returns_true_if_running_coroutine_is_main_one()
    local _, ismaincoro = coroutine.running()
    assert_equal(true, ismaincoro)
  end

  function test_coroutine_running_returns_false_if_running_coroutine_is_not_main_one()
    local ismaincoro = true
    local corothread = coroutine.create(
      function()
        _, ismaincoro = coroutine.running(corothread)
      end
    )
    coroutine.resume(corothread)
    assert_equal(false, ismaincoro)
  end

end

-- The following 2 tests only apply to 5.3, since coroutine.isyieldable doesn't exist in previous versions of Lua
if lua_greater_or_equal_5_3() then

  function test_main_thread_is_not_yieldable()
    assert_equal(false, coroutine.isyieldable())
  end

  function test_running_coroutine_is_yieldable()
    local isyieldable = false
    local corothread = coroutine.create(
      function()
        isyieldable = coroutine.isyieldable()
      end
    )
    coroutine.resume(corothread)
    assert_equal(true, isyieldable)
  end

end

function test_resume_with_no_yield_passes_arguments_to_coroutine_main_function()
  local myvar
  local corothread = coroutine.create(
    function(arg1)
      myvar = arg1
    end
  )
  coroutine.resume(corothread, 42)
  assert_equal(42, myvar)
end

function test_yield_returns_arguments_from_corresponding_resume_call()
  local retval1, retval2
  local corothread = coroutine.create(
    function()
      retval1, retval2 = coroutine.yield()
    end
  )
  coroutine.resume(corothread)
  coroutine.resume(corothread, 42, 21)
  assert_equal(42, retval1)
  assert_equal(21, retval2)
end

function test_arguments_to_yield_are_passed_to_resume_call()
  local corothread = coroutine.create(
    function()
      coroutine.yield("mystatus")
    end
  )
  local errorfree, argumentfromyield = coroutine.resume(corothread)
  assert_equal(true, errorfree)
  assert_equal('mystatus', argumentfromyield)
end

function test_return_values_from_main_function_go_to_corresponding_resume()
  local corothread = coroutine.create(
    function()
      return 84, 168
    end
  )
  local errorfree, retval1, retval2 = coroutine.resume(corothread)
  assert_equal(true, errorfree)
  assert_equal(84, retval1)
  assert_equal(168, retval2)
end

function test_coroutine_wrap_returns_function()
  local wrapfunc = coroutine.wrap(
    function()
    end
  )
  assert_equal('function', type(wrapfunc))
end

function test_coroutine_wrap_does_not_resume_created_coroutine()
  local isexecuted = false
  local wrapfunc = coroutine.wrap(
    function()
      isexecuted = true
    end
  )
  assert_equal(false, isexecuted)
end

function test_calling_function_returned_by_wrap_resumes_created_coroutine()
  local isexecuted = false
  local wrapfunc = coroutine.wrap(
    function()
      isexecuted = true
    end
  )
  wrapfunc()
  assert_equal(true, isexecuted)
end

function test_errors_inside_coroutines_are_propagated_to_caller()
  -- note that with coroutine.wrap, the behaviour is different:
  -- here, the error is raised immediately
  local corothread = coroutine.create(
    function()
      error("Error inside coroutine")
    end
  )
  errorfree, message = coroutine.resume(corothread)
  assert_equal(false, errorfree)
  assert_equal(true, "Error inside coroutine" == string.match(message, "Error inside coroutine"))
end

function test_coroutines_can_called_recursively()
  local function rec_reverse(char)
    if char then
      rev_string = rec_reverse(coroutine.yield()) or ''
      return rev_string .. char
    end
  end

  local wrap_func = coroutine.wrap(rec_reverse)
  string.gsub("Reversing with coroutines", ".", wrap_func)
  assert_equal('senituoroc htiw gnisreveR', wrap_func())
end

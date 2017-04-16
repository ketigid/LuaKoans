--[[
  EXERCISE: Monkey-patching strings

  With all you have learnt now, you should be able to do this exercise

  Add the necessary code below so that the test at the end passes

]]

-- INSERT YOUR CODE HERE
function string:starts_with(x)
  start,_ = self:find('^'..x)
  if start == 1 then
    return true
  else
    return false
  end
end

function string:ends_with(x)
  _,last = self:find(x..'$')
  if last == #self then
    return true
  else
    return false
  end
end

-- END OF CODE INSERT

function test_starts_with()
  local str = "Lua is awesome"

  assert_true(str:starts_with("L"))
  assert_true(str:starts_with("Lua"))
  assert_true(str:starts_with("Lua is"))
  assert_not(str:starts_with("awe"))
end

function test_ends_with()
  local str = "Lua is awesome"

  assert_true(str:ends_with("e"))
  assert_true(str:ends_with("some"))
  assert_true(str:ends_with("awesome"))
  assert_not(str:ends_with("awe"))
end

-- hint: string == getmetatable("").__index

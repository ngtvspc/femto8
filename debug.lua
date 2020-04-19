-- an attempt at a PICO-8 debugger

function _debug_conf(...)
 local t_varargs = {...}
 local r_callbacks = {}
 for callback in all(t_varargs) do
  local wrapped = _debug_wrap(callback)
  add(r_callbacks, wrapped)
  menuitem(#r_callbacks+1, "", function() wrapped() end)
  printh(#r_callbacks, "space_invaders")
  _set_trace()
 end
 menuitem(1, "_stop", function() stop() end)
 return debug.unpack(r_callbacks)
end

function _unpack(t)
 if #t == 0 then
  return
 else
  local first = t[1]
  del(t, first)
  return first, _unpack(t)
 end
end

function _debug_wrap(func)
 local inner = function()
  local c = cocreate(func)
  local active, err = coresume(c)
  while active do
   active, err = coresume(c)
  end
 end
 return inner
end

function _debug_menu()
 
 menuitem(2, "_shutdown", function() extcmd("shutdown") end)
 menuitem(3, "_shutdown", function() extcmd("shutdown") end)
 menuitem(4, "_shutdown", function() extcmd("shutdown") end)
 menuitem(5, "_shutdown", function() extcmd("shutdown") end)
end

function _set_trace()
 extcmd("pause")
 yield()
end

-- as follows is the public API
debug = {}
debug.set_trace = _set_trace
debug.conf = _debug_conf
debug.unpack = _unpack

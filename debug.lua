-- an attempt at a PICO-8 debugger

function _debug_conf(...)
 local t_varargs = {...}
 local r_callbacks = {}
 for callback in all(t_varargs) do
  local wrapped = _debug_wrap(callback)
  add(r_callbacks, wrapped)
  menuitem(#r_callbacks+1, "conf function "..tostr(#r_callbacks), function() wrapped() end)
 end
 menuitem(1, "_stop", function() stop() end)
 return debug.unpack(r_callbacks)
end

-- a simplistic game loop to replace PICO-8s and support coroutine resumption
function _debug_game_loop(update, draw, init)
 local debug_init = function()
  init()
  while true do
   update()
   draw()
   flip()
  end
 end
 return debug_init
end

function _debug_wrap(func)
 local inner = function()
  local c = cocreate(func)
  local active, err = coresume(c)
  while active do
   extcmd("pause")
   active, err = coresume(c)
  end
 end
 return inner
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

-- as follows is the public API
debug = {}
debug.set_trace = yield
debug.unpack = _unpack
debug.replace_game_loop = _debug_game_loop

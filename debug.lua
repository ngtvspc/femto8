-- an attempt at a PICO-8 debugger

function _debug()

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

 -- a barebones game loop to replace PICO-8s and support coroutine resumption
 function _debug_game_loop(update, draw, init)
  init = init or function() return end
  local debug_init = function()
   local co_init = _debug_wrap(init)
   co_init()
   while true do
    local co_update = _debug_wrap(update)
    local co_draw = _debug_wrap(draw)
    co_update()
    co_draw()
    flip()
   end
  end
  return debug_init
 end

 function _debug_wrap(func)
  local inner = function()
   local c = cocreate(func)
   local active, err = coresume(c)
   while active and costatus(c) != "dead" do
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

 function _pprint(val, filename)
  -- pretty print
  if type(val) == "table" then
   printh(val, filename)
  end
 end

 -- as follows is the public API
 return {
  set_trace=yield,
  unpack=_unpack,
  replace_game_loop=_debug_game_loop,
  pprint=_pprint,
 }
end

debug = _debug()

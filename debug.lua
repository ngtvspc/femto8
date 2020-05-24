-- an attempt at a PICO-8 debugger

function debug(config)

 -- default config
 local config = config or {}

 -- depr, just some interesting ideas here like resuming specific routines
 local function _debug_conf(...)
  local t_varargs = {...}
  local r_callbacks = {}
  for callback in all(t_varargs) do
   local wrapped = _debug_wrap(callback)
   add(r_callbacks, wrapped)
   menuitem(#r_callbacks+1, "conf function "..tostr(#r_callbacks), function() wrapped() end)
  end
  menuitem(1, "_stop", function() stop() end)
  -- should convert this to class based architecture?
  -- debug in this context is referring to a global debug object, not self
  return debug.unpack(r_callbacks)
 end

 local function _debug_wrap(func)
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

 -- a barebones game loop to replace PICO-8s and support coroutine resumption
 local function _debug_game_loop(update, draw, init)
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

 local function _unpack(t)
  if #t == 0 then
   return
  else
   local first = t[1]
   del(t, first)
   return first, _unpack(t)
  end
 end

 local function _pprint(val, filename, indent)
  -- pretty print
  local _indent_str = ""
  local _newline = "\n"
  if indent == nil then
   indent = 1
  elseif indent == 0 then
   _newline = ""
  end
  for x=1,indent do
   _indent_str = _indent_str.." "
  end

  local function _traverse(val, indent_str)
   local _pr_val = ""
   if type(val) == "table" then
    _pr_val=_newline..indent_str.."{"
    -- detect first loop to space out "{" character
    local _first_loop = true
    for key, elem in pairs(val) do
     -- first key has an extra character due to the adding of "{"
     if not _first_loop then
      _pr_val = _pr_val.." "
     end
     _pr_val = _pr_val..key.."=".._traverse(elem, indent_str.._indent_str)..",".._newline..indent_str
     _first_loop = false
    end
    _pr_val=_pr_val.."}"
   else
    _pr_val = tostr(val)
   end
   return _pr_val
  end

  printh(_traverse(val, ""), filename)
 end

 local function _conf_pprint(filename)
  if filename == nil then
   return _pprint
  end
  local function _closure(val, indent)
   return _pprint(val, filename, indent)
  end
  return _closure
 end

 -- as follows is the public API
 return {
  set_trace=yield,
  unpack=_unpack,
  replace_game_loop=_debug_game_loop,
  pprint=_conf_pprint(config.filename),
  configure=debug,
 }
end

debug = debug()

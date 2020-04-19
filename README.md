# FEMTO-8
A small Debugging Util for the PICO-8 Virtual Console, very much a work in progress

## Usage

Include or paste the contents of [debug.lua](debug.lua) into your PICO-8 cartridge. This will provide an table named `debug` with methods attached to it.

```
#include debug.lua

function _init()
 -- lua code
 debug.set_trace() -- execution will pause here
 ...
end

function _draw()
 -- lua code
 debug.set_trace() -- execution pauses here every draw call
 ...
end

_init = debug.replace_game_loop(_update, _draw, _init)
```

See [space_invaders.lua](space_invaders.lua) for a basic working cartridge and usage of `debug`


## Extra API

`debug.unpack` - a useful little util that allows for something similar to tuple unpacking or returning multiple values from a table

```
function multi_return()
 local tab = {1,2,3}
 return debug.unpack(tab)
end

a, b, c = multi_return()
```


## Feature Wishlist
- a way to inspect local variables would be stellar
  - (already attempted to read program memory via peek, seem unable to access variable contents via peek)
- a way to switch to the interpreter and actually evaluate lua
  - (unfortunately doesn't seem possible given limited capabilties of PICO-8)

## Architecture

Current approach uses `_init` in order to take control of the users PICO-8 cart and replace the internal game loop with a barebones loop of our own design. This allows for more predictable resumption of breakpoints. Breakpoints are set internally using `yield()` and execution pausing is done via the pause menu. (This presents some challenges because the pause menu seems to force a resumption of `_draw` and `_update` or `_update60`

Past Approaches:
- [x] Wrapping `_init`, `_update`, `_update60`, and `_draw` in co-routines to allow for resumption after setting breakpoints (broken by PICO-8s own internal game loop)
- [x] Simple pausing using `extcmd("pause")` (too unsophisticated)

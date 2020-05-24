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

The intended debug flow makes use of the pause menu, logging, and eventually `trace()` to provide an easily configured setup for introspecting variables, the call stack, and step by step execution of your cart.


## Extra API

`debug.unpack [table]` - allows for something similar to tuple unpacking or returning multiple values from a table and mostly [cribbed from this](https://gist.github.com/josefnpat/bfe4aaa5bbb44f572cd0#unpack)

```
function multi_return()
 local tab = {1,2,3}
 return debug.unpack(tab)
end

a, b, c = multi_return()
```

`debug.configure [configure table]` - given a table of configuration values, configures the debug library

Supported Configure Table Options:
- `filename` - sets filename printed to by debug library

```
-- setting the global debug to the return value of configure() is required
debug = debug.configure({filename='my_log_file'})
debug.pprint({key='val'})
```

`debug.pprint val filename indent` - pretty prints `val` to the specified `filename` either in the function call or the one configured for the debug library using the specified `indent` for indenting the nested structures. Both `filename` and `indent` are optional.

```
debug.pprint('hello') -- uses builtin printh and prints to host operating system console
debug.pprint('writing to audit.p8l', 'audit', 3) -- pretty print to filename audit.p8l with indent of 3 spaces

debug = debug.configure({filename='log'}) -- configures logger to print to log.p8l
debug.pprint('writing to file log.p8l')

nested_structure = {
 one=1,
 two=2,
 three={'hi', 'hello'}
 four=4,
}
debug..print(nested_structure, 2) -- pretty prints nested_structure with an indent of two spaces
debug..print(nested_structure, 0) -- pretty prints nested_structure with no spaces, should be copy-pastable directly to pico8 console
```


## Feature Wishlist
- [x] pretty printer for tables
- [] add some configurable logging capability and stack printing, the user flow should be:
  - set trace
  - (optionally ask for logged stack)
  - log values of variables
- [] a way to inspect local variables would be stellar
  - (already attempted to read program memory via peek, seem unable to access variable contents via peek)
- [] a way to switch to the interpreter and actually evaluate lua
  - (unfortunately doesn't seem possible given limited capabilties of PICO-8)

## Architecture

Current approach uses `_init` in order to take control of the users PICO-8 cart and replace the internal game loop with a barebones loop of our own design. This allows for more predictable resumption of breakpoints. Breakpoints are set internally using `yield()` and execution pausing is done via the pause menu. (This presents some challenges because the pause menu seems to force a resumption of `_draw` and `_update` or `_update60`

Past Approaches:
- [x] Wrapping `_init`, `_update`, `_update60`, and `_draw` in co-routines to allow for resumption after setting breakpoints (broken by PICO-8s own internal game loop)
- [x] Simple pausing using `extcmd("pause")` (too unsophisticated)

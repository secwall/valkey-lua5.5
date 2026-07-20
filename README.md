# valkey-lua55

A [Lua 5.5](https://www.lua.org/) scripting engine module for
[Valkey](https://github.com/valkey-io/valkey).

This module implements the Valkey scripting-engine module API, providing
`EVAL`, `EVALSHA`, `FUNCTION`, and `SCRIPT` commands backed by an embedded
Lua 5.5 interpreter. It uses a per-user architecture: each authenticated user
gets their own pair of `lua_State` instances (one for `EVAL`, one for
`FUNCTION`), created lazily on first use. This eliminates the need for
readonly-table protection that would otherwise require patching the Lua
implementation.

The bundled Lua 5.5 sources (vendored as a git submodule at `deps/lua`)
are compiled into the module; no external Lua dependency is required at
runtime.

## Build

```sh
./build.sh --release
```

Produces `build/libvalkeylua55.so`.

## Tests

```sh
./build.sh --with-tests
./tests/run-valkey-tests.sh
```

## Loading into Valkey

```
loadmodule /path/to/libvalkeylua55.so
```

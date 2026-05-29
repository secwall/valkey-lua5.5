start_server {tags {"multi-engine"} overrides {lua55.engine-name "lua,lua55,foobar"}} {
    test {Engine registered with 'lua' name} {
        set result [r EVAL "#!lua\nreturn _VERSION" 0]
        assert_match {Lua 5.5*} $result
    }

    test {Engine registered with 'lua55' name} {
        set result [r EVAL "#!lua55\nreturn _VERSION" 0]
        assert_match {Lua 5.5*} $result
    }

    test {Engine registered with 'foobar' name} {
        set result [r EVAL "#!foobar\nreturn _VERSION" 0]
        assert_match {Lua 5.5*} $result
    }

    test {SCRIPT LOAD and EVALSHA with 'lua' engine} {
        set sha [r SCRIPT LOAD "#!lua\nreturn 'test-lua'"]
        set result [r EVALSHA $sha 0]
        assert_equal $result {test-lua}
    }

    test {SCRIPT LOAD and EVALSHA with 'lua55' engine} {
        set sha [r SCRIPT LOAD "#!lua55\nreturn 'test-lua55'"]
        set result [r EVALSHA $sha 0]
        assert_equal $result {test-lua55}
    }

    test {SCRIPT LOAD and EVALSHA with 'foobar' engine} {
        set sha [r SCRIPT LOAD "#!foobar\nreturn 'test-foobar'"]
        set result [r EVALSHA $sha 0]
        assert_equal $result {test-foobar}
    }

    test {'lua' 'lua55' 'foobar' all use Lua 5.5} {
        set lua_v [r EVAL "#!lua\nreturn _VERSION" 0]
        set lua55_v [r EVAL "#!lua55\nreturn _VERSION" 0]
        set foobar_v [r EVAL "#!foobar\nreturn _VERSION" 0]
        assert_equal $lua_v $lua55_v
        assert_equal $lua55_v $foobar_v
    }
}

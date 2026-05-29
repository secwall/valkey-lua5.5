proc get_function_code {engine library_name function_name body} {
    return [format "#!%s name=%s\nserver.register_function('%s', function(KEYS, ARGV)\n %s \nend)" $engine $library_name $function_name $body]
}

start_server {tags {"engine-routing"}} {
    test {No-shebang EVAL routes to lua55 (default engine)} {
        set result [r EVAL "return _VERSION" 0]
        assert_match {Lua 5.5*} $result
    }

    test {#!lua shebang routes to lua55} {
        set result [r EVAL "#!lua\nreturn _VERSION" 0]
        assert_match {Lua 5.5*} $result
    }

    test {FUNCTION with #!lua shebang uses lua55} {
        r FUNCTION LOAD [get_function_code lua lib_routing get_version {return _VERSION}]
        set result [r FCALL get_version 0]
        assert_match {Lua 5.5*} $result
    }

    test {server.* and redis.* aliases both work} {
        r SET routing_key val
        set v1 [r EVAL "return server.call('GET', KEYS\[1\])" 1 routing_key]
        set v2 [r EVAL "return redis.call('GET', KEYS\[1\])" 1 routing_key]
        assert_equal $v1 $v2
        assert_equal $v1 {val}
    }
}

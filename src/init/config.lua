local _M = {}

function _M.is_debug()
    return true
end

function _M.pg_config()
    return {
        host = "127.0.0.1",
        port = "5432",
        database = "z-blog",
        user = "thunk"
    }
end

return _M
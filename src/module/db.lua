local pgmoon = require "pgmoon"
local encode_array = require("pgmoon.arrays").encode_array

local _M = { _VERSION = "0.01"}

local function config()
    return {
        host = "127.0.0.1",
        port = "5432",
        database = "z-blog",
        user = "z-blog"
    }
end

-- 参照pgmoon:escape_literal
function _M.quote(val)
    -- ngx.null 等于 null
    if val and val ~= ngx.null then
        -- 防止SQL注入，OpenResty自带
        return ndk.set_var.set_quote_pgsql_str(val)
    else
        return "null"
    end
    --local type = type(val)
    --if "string" == type then
    --    -- ngx.quote_sql_str按MySQL规则
    --    --return ngx.quote_sql_str(val)
    --    return "'" .. tostring((val:gsub("'", "''"))) .. "'"
    --elseif "number" == type then
    --    return tostring(val)
    --elseif "boolean" == val then
    --    return val and "TRUE" or "FALSE"
    --else
    --    return "null"
    --end
end

-- pgmoon 插入数组时进行编码
function _M.encode_arr(arr)
    if type(arr) == 'table' and #arr > 0 then
        return encode_array(arr)
    else
        return "null"
    end
end

function _M.query(sql)
    local pg = pgmoon.new(config())

    local success, err = pg:connect()
    if not success then
        ngx.log(ngx.ERR, 'query_db connect pg error#', err)
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end

    -- num_queries, 几条sql语句执行
    local result, num_queries = pg:query(sql)

    pg:keepalive()

    return result
end

return _M
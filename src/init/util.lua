local _M = {}

local function filter_method(method)
    if method ~= ngx.req.get_method() then
        ngx.log(ngx.ERR, "request_method=", ngx.req.get_method(), ", non match=" .. method)
        ngx.exit(ngx.HTTP_NOT_FOUND)
    end
end

function _M.filter_non_get_method()
    filter_method('GET')
end

function _M.filter_non_post_method()
    filter_method('POST')
end

function _M.get_client_ip()
    local headers = ngx.req.get_headers()
    local ip = headers["X-REAL-IP"] or headers["X_FORWARDED_FOR"] or ngx.var.remote_addr or "0.0.0.0"
    return ip
end

-- 返回woothee对象
-- {"name": "xxx", "category": "xxx", "os": "xxx", "version": "xxx", "vendor": "xxx"}
-- name => name of browser (or string like name of user-agent)
-- category => "pc", "smartphone", "mobilephone", "appliance", "crawler", "misc", "unknown"
-- os => os from user-agent, or carrier name of mobile phones
-- version => version of browser, or terminal type name of mobile phones
-- os_version => NT 10.0 .etc
-- 根据category是否为crawler来判断是否是爬虫
function _M.parse_ua()
    return woothee.parse(ngx.var.http_user_agent)
end

-- 判断是否是爬虫，其实也是根据category是否为crawler来判断
function _M.is_crawler()
    return woothee.is_crawler(ngx.var.http_user_agent)
end

function _M.query_db(sql)
    local pg = pgmoon.new(config.pg_config())

    local success, err = pg:connect()
    if err then
        ngx.log(ngx.ERR, 'connect pg error#', err)
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end

    -- num_queries, 几条sql语句执行
    local result, num_queries = pg:query(sql)

    pg:keepalive()

    return result
end

return _M
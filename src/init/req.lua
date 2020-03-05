local _M = {}

local function filter_method(method, req_method)
    if method ~= req_method then
        ngx.log(ngx.ERR, "request_method=", req_method, ", non match=" .. method)
        return _M.method_not_allowed(req_method)
    end
end

function _M.filter_non_get_method(req_method)
    filter_method('GET', req_method)
end

function _M.filter_non_post_method(req_method)
    filter_method('POST', req_method)
end

-- 返回woothee对象
-- {"name": "xxx", "category": "xxx", "os": "xxx", "version": "xxx", "vendor": "xxx"}
-- name => name of browser (or string like name of user-agent)
-- category => "pc", "smartphone", "mobilephone", "appliance", "crawler", "misc", "unknown"
-- os => os from user-agent, or carrier name of mobile phones
-- version => version of browser, or terminal type name of mobile phones
-- os_version => NT 10.0 .etc
-- 根据category是否为crawler来判断是否是爬虫
-- 判断是否是爬虫，其实也是根据category是否为crawler来判断
--function _M.is_crawler(ua)
--    return woothee.is_crawler(ua)
--end
function _M.parse_ua(ua)
    return woothee.parse(ua)
end

-- 自定义返回内容
-- 400
function _M.bad_request()
    ngx.status = ngx.HTTP_BAD_REQUEST
    local res = {
        timestamp = ngx.time(),
        status = 400,
        error = "Bad Request",
        message = "Bad Request"
    }
    ngx.say(json.encode(res))
    return ngx.exit(ngx.HTTP_BAD_REQUEST)
end

-- 405status
function _M.method_not_allowed(method)
    ngx.status = ngx.HTTP_NOT_ALLOWED
    local res = {
        timestamp = ngx.time(),
        status = 405,
        error = "Method Not Allowed",
        message = "Request method '" .. method .. "' not supported"
    }
    ngx.say(json.encode(res))
    return ngx.exit(ngx.HTTP_NOT_ALLOWED)
end

return _M
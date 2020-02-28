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

-- 返回woothee对象
-- {"name": "xxx", "category": "xxx", "os": "xxx", "version": "xxx", "vendor": "xxx"}
function _M.parse_ua()
    return woothee.parse(ngx.var.http_user_agent)
end

return _M
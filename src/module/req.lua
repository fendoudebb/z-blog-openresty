local json = require "cjson.safe"
local woothee = require "resty.woothee"

local _M = { _VERSION = "0.01" }

function _M.get_ip_from_headers(headers)
    return headers["X-REAL-IP"] or headers["X_FORWARDED_FOR"] or ngx.var.remote_addr or "0.0.0.0"
end

function _M.is_get_method(req_method)
    return "GET" == req_method
end

function _M.is_post_method(req_method)
    return "POST" == req_method
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

function _M.request_error(status_code, info)
    ngx.status = status_code
    ngx.say(json.encode(info))
    return ngx.exit(status_code)
end

-- 自定义返回内容
-- 400
function _M.bad_request()
    return _M.request_error(ngx.HTTP_BAD_REQUEST, {
        timestamp = ngx.time(),
        status = 400,
        error = "Bad Request",
        message = "Bad Request"
    })
end

-- 401
function _M.unauthorized()
    return _M.request_error(ngx.HTTP_UNAUTHORIZED, {
        timestamp = ngx.time(),
        status = 401,
        error = "unauthorized",
        message = "unauthorized"
    })
end

-- 405status
function _M.method_not_allowed()
    return _M.request_error(ngx.HTTP_NOT_ALLOWED, {
        timestamp = ngx.time(),
        status = 405,
        error = "Method Not Allowed",
        --message = "Request method '" .. method .. "' not supported"
    })
end

function _M.valid_http_referer(referer, valid_referer)
    if not referer then
        ngx.log(ngx.ERR, "[valid_http_referer] referer is nil, valid_referer#", valid_referer)
        return false
    end

    local captures, err = ngx.re.match(referer, valid_referer)

    if not captures then
        ngx.log(ngx.ERR, "[valid_http_referer] referer#", referer, " valid_referer#", valid_referer, ", err#", err)
        return false
    end
    return true
end

function _M.get_page_size(args)
    -- ngx.req.get_uri_args()
    -- ngx.ctx.body_data
    local page = tonumber(args.page or 1)
    local size = tonumber(args.size or 20)

    if page < 1 then
        page = 1
    end

    return {
        page = page,
        limit = size,
        offset = (page - 1) * size
    }
end

return _M
local req = require "module.req"

local headers = ngx.req.get_headers()
ngx.ctx.client_ip = headers["X-REAL-IP"] or headers["X_FORWARDED_FOR"] or ngx.var.remote_addr or "0.0.0.0"

ngx.ctx.ua = req.parse_ua(ngx.var.http_user_agent)

if not req.is_get_method(ngx.var.request_method) then
    return req.method_not_allowed()
end

local category = ngx.ctx.ua.category
ngx.ctx.is_mobile = ("pc" ~= category or "smartphone" == category or "mobilephone" == category)
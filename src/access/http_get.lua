local req = require "module.req"

ngx.ctx.client_ip = req.get_ip_from_headers(ngx.req.get_headers())

ngx.ctx.ua = req.parse_ua(ngx.var.http_user_agent)

if not req.is_get_method(ngx.var.request_method) then
    return req.method_not_allowed()
end

local category = ngx.ctx.ua.category
ngx.ctx.is_mobile = ("pc" ~= category or "smartphone" == category or "mobilephone" == category)
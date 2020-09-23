local json = require "cjson.safe"
local req = require "module.req"

ngx.ctx.client_ip = req.get_ip_from_headers(ngx.req.get_headers())

ngx.ctx.ua = req.parse_ua(ngx.var.http_user_agent)

if not req.is_post_method(ngx.var.request_method) then
   return req.method_not_allowed()
end

ngx.req.read_body()
local body_data = ngx.req.get_body_data()
if not body_data then
    --ngx.log(ngx.ERR, "http post body data is nil, request url#", ngx.var.request_uri)
    return req.bad_request()
end

local value = json.decode(body_data)
if not value then
    --ngx.log(ngx.ERR, "http post decode body data err#", err)
    return req.bad_request()
end

ngx.ctx.body_data = value
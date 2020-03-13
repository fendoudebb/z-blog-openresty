local json = require "cjson.safe"
local req = require "module.req"

local headers = ngx.req.get_headers()
ngx.ctx.client_ip = headers["X-REAL-IP"] or headers["X_FORWARDED_FOR"] or ngx.var.remote_addr or "0.0.0.0"

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

local value, err = json.decode(body_data)
if not value then
    --ngx.log(ngx.ERR, "http post decode body data err#", err)
    return req.bad_request()
end

ngx.ctx.body_data = value
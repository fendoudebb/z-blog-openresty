local json = require "cjson.safe"
local req = require "module.req"

if not req.is_post_method(ngx.var.request_method) then
    return req.method_not_allowed()
end

local token = ngx.var.http_token

if not token then
    return req.bad_request()
end

local memory = ngx.shared.memory
local login_key = "dashboard-login-" .. token
local user_info_json_str = memory:get(login_key)
if not user_info_json_str then
    return ngx.say(json.encode(req.unauthorized()))
end

memory:expire(login_key, 604800)

ngx.ctx.user_info = json.decode(user_info_json_str)

ngx.req.read_body()
local body_data = ngx.req.get_body_data()
if not body_data then
    return req.bad_request()
end

local value = json.decode(body_data)
if not value then
    return req.bad_request()
end

ngx.ctx.body_data = value
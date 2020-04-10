local json = require "cjson.safe"
local const = require "module.const"
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
memory:delete(login_key)

ngx.say(json.encode(const.ok()))
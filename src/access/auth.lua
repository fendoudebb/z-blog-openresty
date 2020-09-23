local json = require "cjson.safe"
local req = require "module.req"

if not req.is_post_method(ngx.var.request_method) then
    return req.method_not_allowed()
end

local token = ngx.var.http_token

if not token then
    ngx.log(ngx.ERR, "auth missing token#" .. ngx.var.http_user_agent)
    return req.bad_request()
end

local memory = ngx.shared.memory
local login_key = "dashboard-login-" .. token
local user_info_json_str = memory:get(login_key)
if not user_info_json_str then
    ngx.log(ngx.ERR, "auth missing login info, token#" .. token)
    return ngx.say(json.encode(req.unauthorized()))
end

local user_info = json.decode(user_info_json_str)

local client_ip = req.get_ip_from_headers(ngx.req.get_headers())

if user_info.ip ~= client_ip then
    ngx.log(ngx.ERR, "auth ip mismatch, login ip#" .. user_info.ip .. ", request ip#" .. client_ip)
    return ngx.say(json.encode(req.unauthorized()))
end

if user_info.ua ~= ngx.var.http_user_agent then
    ngx.log(ngx.ERR, "auth ua mismatch, login ua#" .. user_info.ua .. ", request ip#" .. ngx.var.http_user_agent)
    return ngx.say(json.encode(req.unauthorized()))
end

memory:expire(login_key, 604800)

ngx.ctx.user_info = user_info

local content_type = ngx.var.http_content_type

if ngx.re.match(content_type, "application/json") then
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
elseif ngx.re.match(content_type, "multipart/form-data") then

else
    ngx.log(ngx.ERR, "auth error content-type#" .. content_type)
    return req.bad_request()
end
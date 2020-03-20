local json = require "cjson.safe"
local const = require "module.const"
local db = require "module.db"
local req = require "module.req"

local username = ngx.ctx.body_data.username
local password = ngx.ctx.body_data.password

if not username then
    ngx.log(ngx.ERR, "[dashboard login] username is nil")
    return req.bad_request()
end

if not password then
    ngx.log(ngx.ERR, "[dashboard login] password is nil, username#", username)
    return req.bad_request()
end

local sql = [[
select id, password, roles from "user" where username = %s
]]

local result = db.query(string.format(sql, db.val_escape(username)))
ngx.log(ngx.ERR, json.encode(result))
local user = result[1]

if not user or password ~= user.password then
    return ngx.say(json.encode(const.login_fail()))
end

local token = ngx.md5(user.id .. ngx.now())

local user_info = {
    id = user.id,
    username = username,
    roles = user.roles,
    ip = ngx.ctx.client_ip,
    ua = ngx.var.http_user_agent
}

local memory = ngx.shared.memory
local success, err = memory:set("dashboard-login-" .. token, json.encode(user_info), 604800)
if not success then
    return ngx.say(json.encode(const.fail(err)))
end

return ngx.say(json.encode(const.ok({
    token = token,
    roles = user.roles
})))

--[[
{
    "msg": "请求成功",
    "code": 0,
    "data": {
        "token": "c8ce0ace8cd7f94e5b8a22486ec76e8c",
        "roles": [
            "ROLE_ADMIN"
        ]
    }
}
]]



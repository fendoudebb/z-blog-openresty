local json = require "cjson.safe"
local const = require "module.const"
local db = require "module.db"
local req = require "module.req"

local id = ngx.ctx.body_data.id
local status = ngx.ctx.body_data.status

if type(id) ~= "number" or type(status) ~= "number" or status > 1 then
    return req.bad_request()
end

local sql = [[
update post set post_status=%d where id=%d
]]

local update_result = db.query(string.format(sql, status, id))

if update_result.affected_rows < 1 then
    ngx.say(json.encode(const.fail()))
else
    ngx.say(json.encode(const.ok()))
end

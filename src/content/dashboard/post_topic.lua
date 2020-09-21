local json = require "cjson.safe"
local const = require "module.const"
local db = require "module.db"
local req = require "module.req"

local post_id = ngx.ctx.body_data.post_id
local topic = ngx.ctx.body_data.topic

if type(post_id) ~= "number" then
    return req.bad_request()
end

local req_url = ngx.var[1]

local sql
if req_url == "add" then
    -- 增
    sql = "update post set topics=array_append(topics, %s), update_ts=current_timestamp where id = %d"
else
    -- 删
    sql = "update post set topics=array_remove(topics, %s), update_ts=current_timestamp where id = %d"
end

db.query(string.format(sql, db.quote(topic), post_id))

ngx.say(json.encode(const.ok()))

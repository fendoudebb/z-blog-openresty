local json = require "cjson.safe"
local const = require "module.const"
local db = require "module.db"
local req = require "module.req"
local util = require "module.util"

local post_id = ngx.ctx.body_data.post_id
local nickname = ngx.ctx.body_data.nickname
local content = ngx.ctx.body_data.content
local client_ip = ngx.ctx.client_ip
local ua = ngx.ctx.ua;

if type(post_id) ~= "number" then
    ngx.log(ngx.ERR, "[post comment] post_id type ~= number#", type(post_id))
    return req.bad_request()
end

if not nickname then
    ngx.log(ngx.ERR, "[post comment] nickname is nil, post_id#", post_id)
    return req.bad_request()
end

if not content then
    ngx.log(ngx.ERR, "[post comment] content is nil, post_id#", post_id)
    return req.bad_request()
end

local referer = ngx.var.http_referer

local valid_referer = "/p/" .. post_id .. ".html"

req.valid_http_referer(referer, valid_referer)

local select_sql = [[
select
id
from post where id = %d
]]
local result = db.query(string.format(select_sql, post_id))

local post = result[1]

if post == nil then
    return ngx.say(json.encode(const.post_not_exist))
end

local sql_value = string.format([[
'id', nextval('post_comment_id_seq')::regclass,
'ip', '%s',
'address', %s,
'comment_date', '%s',
'comment_timestamp', %d,
'ua', %s,
'browser', '%s',
'browser_platform', '%s',
'browser_version', '%s',
'browser_vendor', '%s',
'os', '%s',
'os_version', '%s',
'nickname', %s,
'content', %s,
'status', 'ONLINE',
'floor', comment_count + 1
]], client_ip, db.val_escape(util.query_ip(client_ip)), ngx.today(), ngx.time(), db.val_escape(ngx.var.http_user_agent), ua.name, ua.category, ua.version, ua.vendor, ua.os, ua.os_version, db.val_escape(nickname), db.val_escape(content))


local update_sql = string.format([[
update post set post_comment =
(
    case when post_comment is not null then jsonb_build_object(%s) || post_comment
    else jsonb_build_array(jsonb_build_object(%s))
    end
), comment_count = comment_count + 1
where id = %d
]], sql_value, sql_value, post_id)

db.query(update_sql)

ngx.say(json.encode(const.ok))
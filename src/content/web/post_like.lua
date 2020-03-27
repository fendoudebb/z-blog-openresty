local json = require "cjson.safe"
local const = require "module.const"
local db = require "module.db"
local req = require "module.req"
local util = require "module.util"

local post_id = ngx.ctx.body_data.post_id
local client_ip = ngx.ctx.client_ip
local ua = ngx.ctx.ua;

local referer = ngx.var.http_referer
local valid_referer = "/p/" .. post_id .. ".html"
local valid_result = req.valid_http_referer(referer, valid_referer)
if not valid_result then
    return req.bad_request()
end

if type(post_id) ~= "number" then
    ngx.log(ngx.ERR, "[post like] post_id type ~= number#", type(post_id))
    return req.bad_request()
end

--select
--id, title, keywords, description, topics, content_html, word_count, post_status,
--pv, like_count, comment_count, comment_status, to_char(create_ts, 'YYYY-MM-DD') as create_ts, post_comment,
--post_like @> '[{"ip":"]] .. ngx.ctx.client_ip .. [["}]'::jsonb as is_liked
--from post where id = ]] .. ngx.var[1]

local select_sql = [[select post_status, post_like @> '[{"ip":"%s"}]' as is_liked from post where id = %d]]
local result = db.query(string.format(select_sql, client_ip, post_id))

local post = result[1]

if not post or post.post_status ~= 0 then
    return req.request_error(ngx.HTTP_NOT_FOUND, const.post_not_exist())
end

if post.is_liked then
    return req.request_error(ngx.HTTP_CONFLICT, const.post_like_already())
end

local sql_value = string.format([[
'id', nextval('post_like_id_seq'),
'ip', '%s',
'address', %s,
'like_date', '%s',
'like_timestamp', %d,
'ua', %s,
'browser', '%s',
'browser_platform', '%s',
'browser_version', '%s',
'browser_vendor', '%s',
'os', '%s',
'os_version', '%s']], client_ip, db.val_escape(util.query_ip(client_ip)), ngx.today(), ngx.time(), db.val_escape(ngx.var.http_user_agent), ua.name, ua.category, ua.version, ua.vendor, ua.os, ua.os_version)

local update_sql = string.format([[
update post set post_like =
(
    case when post_like is not null then jsonb_build_object(%s) || post_like
    else jsonb_build_array(jsonb_build_object(%s))
    end
), like_count = like_count + 1
where id = %d and post_like @> '[{"ip":"%s"}]' is not true;
]], sql_value, sql_value, post_id, client_ip)

local update_result = db.query(update_sql)

if update_result.affected_rows < 1 then
    ngx.say(json.encode(const.fail()))
else
    ngx.say(json.encode(const.ok()))
end
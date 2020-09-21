local json = require "cjson.safe"
local const = require "module.const"
local db = require "module.db"
local req = require "module.req"

local post_id = ngx.ctx.body_data.post_id
local sql_args = req.get_page_size(ngx.ctx.body_data)

if type(post_id) ~= "number" then
    return req.bad_request()
end

local req_url = ngx.var[1]

--    with t as (
--        select jsonb_array_elements(post_comment) as data from post where id = %d limit %d offset %d
--    )
--    select jsonb_agg(data) as comments from t

-- select jsonb_agg(comment_arr) as comments from post, jsonb_array_elements(post_comment) as comment_arr where id = %d limit %d offset %d

local sql
if req_url == "list" then
    -- 评论列表
    sql = [[
    select jsonb_array_length(post_comment) as count from post where id=%d;
    with t as (
        select jsonb_array_elements(post_comment) as data from post where id=%d limit %d offset %d
    )
    select jsonb_agg(data) as comments from t
    ]]
    sql = string.format(sql, post_id, post_id, sql_args.limit, sql_args.offset)

    local result = db.query(sql)

    ngx.say(json.encode(const.ok({
        count = result[1][1].count,
        comments = result[2][1].comments
    })))
elseif req_url == "delete" then
    local comment_id = ngx.ctx.body_data.comment_id
    if type(comment_id) ~= "number" then
        return req.bad_request()
    end
    -- 删除评论
    -- 此处element ->> 'id' = '100'中的id的value必须是''单引号引起来的
    sql = [[
    update post set post_comment=jsonb_set(
        post_comment, ARRAY[(select index-1 from jsonb_array_elements(post_comment) WITH ORDINALITY arr(element, index) where element ->> 'id' = '%d')::text, 'status'], '"OFFLINE"', false
    ) where id=%d
    ]]
    local result = db.query(string.format(sql, comment_id, post_id))

    if result then
        ngx.say(json.encode(const.ok()))
    else
        ngx.say(json.encode(const.fail()))
    end
else
    local comment_id = ngx.ctx.body_data.comment_id
    if type(comment_id) ~= "number" then
        return req.bad_request()
    end
    local content = ngx.ctx.body_data.content
    if type(content) ~= "string" then
        return req.bad_request()
    end

    local ua = req.parse_ua(ngx.var.http_user_agent)

    local sql_value = string.format([[
    'id', nextval('post_comment_id_seq'),
    'ip', '%s',
    'reply_date', '%s',
    'reply_timestamp', %d,
    'ua', %s,
    'browser', '%s',
    'browser_platform', '%s',
    'browser_version', '%s',
    'browser_vendor', '%s',
    'os', '%s',
    'os_version', '%s',
    'content', %s,
    'status', 'ONLINE'
    ]], ngx.ctx.client_ip, ngx.today(), ngx.time(), db.quote(ngx.var.http_user_agent), ua.name, ua.category, ua.version, ua.vendor, ua.os, ua.os_version, db.quote(content))


    -- 回复评论
    sql = [[
    with t as (
    select (index-1)::text as i, element->>'replies' as replies from post, jsonb_array_elements(post_comment) WITH ORDINALITY arr(element, index) where element ->> 'id' = '%d'
    )
    update post set post_comment=case when (select replies from t) is null then
    jsonb_set(
        post_comment, ARRAY[(select i from t),'replies'],jsonb_build_array(jsonb_build_object(%s))
    )
    else
    jsonb_insert(
        post_comment, ARRAY[(select i from t),'replies','0'],jsonb_build_object(%s)
    )
    end
    where id=%d
    ]]

    db.query(string.format(sql, comment_id, sql_value, sql_value, post_id))
    ngx.say(json.encode(const.ok()))
end


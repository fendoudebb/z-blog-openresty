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

local sql
if req_url == "list" then
    -- 评论列表
    sql = [[
    select jsonb_array_length(post_comment) as count from post where id = %d;
    select jsonb_agg(comment_arr) as comments from post, jsonb_array_elements(post_comment) as comment_arr where id = %d limit %d offset %d
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
    update post set post_comment = jsonb_set(
        post_comment, ARRAY[(select index-1 from jsonb_array_elements(post_comment) WITH ORDINALITY arr(element, index) where element ->> 'id' = '%d')::text, 'status'], '"OFFLINE"', false
    ) where id = %d
    ]]
    sql = string.format(sql, comment_id, post_id)

    local result = db.query(sql)

    if result then
        ngx.say(json.encode(const.ok()))
    else
        ngx.say(json.encode(const.fail()))
    end

else
    -- 回复评论
    sql = "update post set topics = array_remove(topics, %s) where id = %d"
end


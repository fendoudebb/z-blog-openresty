local json = require "cjson.safe"
local const = require "module.const"
local db = require "module.db"
local req = require "module.req"

local sql_args = req.get_page_size(ngx.ctx.body_data)

local post_id = ngx.ctx.body_data.post_id
local rank_type = ngx.ctx.body_data.rank_type


local sql = [[
select count(*) as count from post;
select id, title, pv, post_status, prop, like_count, comment_count, topics, to_char(create_ts, 'YYYY-MM-DD hh24:MI:ss') as create_ts from post order by create_ts desc limit %d offset %d
]]


local result = db.query(string.format(sql, sql_args.limit, sql_args.offset))

ngx.say(json.encode(const.ok({
    count = result[1][1].count,
    posts = result[2]
})))
local template = require "resty.template"
local db = require "module.db"
local req = require "module.req"

local sql_args = req.get_page_size(ngx.req.get_uri_args())

local sql = "select id, title, description, pv, like_count, comment_count, topics, to_char(create_ts, 'YYYY-MM-DD') as create_ts from post where post_status = 0 order by id desc limit %d offset %d"

local result = db.query(string.format(sql, sql_args.limit, sql_args.offset))

local memory = ngx.shared.memory
-- sync_es.lua 中清除缓存
local online_post_count = memory:get("online_post_count")
if not online_post_count then
    online_post_count = db.query("select count(*) as count from post where post_status = 0")[1].count
    memory:set("online_post_count", online_post_count)
end

template.render("index.html", { posts = result, cur_page = sql_args.page, sum_page = math.ceil(online_post_count / sql_args.limit) })
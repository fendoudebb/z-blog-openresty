local template = require "resty.template"
local db = require "module.db"
local req = require "module.req"

local sql_args = req.get_page_size(ngx.req.get_uri_args())

local topic = ngx.var[1]
local escape_topic = db.val_escape(topic)

local sql = [[
select id, title, description, pv, like_count, comment_count, topics, to_char(create_ts, 'YYYY-MM-DD') as create_ts from post where post_status=0 and %s=ANY(topics) limit %d offset %d;
select count(*) as count from post where post_status=0 and %s=ANY(topics);
]]

local result = db.query(string.format(sql, escape_topic, sql_args.limit, sql_args.offset, escape_topic))

template.render("topic.html", {
    posts = result[1],
    topic = topic,
    cur_page = sql_args.page,
    sum_page = math.ceil(result[2][1].count / sql_args.limit)
})
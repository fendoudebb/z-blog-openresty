local template = require "resty.template"
local db = require "module.db"

local args = ngx.req.get_uri_args()
local page = 1;
if args then
    local arg_page = args.page
    if type(arg_page) == "string" then
        page = tonumber(arg_page)
    end
end

if page < 1 then
    page = 1
end

local size = 20;

local offset = (page - 1) * size

local topic = ngx.var[1]
local escape_topic = db.val_escape(topic)

local sql = [[
select id, title, description, pv, like_count, comment_count, topics, to_char(create_ts, 'YYYY-MM-DD') as create_ts from post where post_status = 0 and %s=ANY(topics) limit %d offset %d;
select count(*) as count from post where post_status = 0 and %s=ANY(topics);
]]

local result = db.query(string.format(sql, escape_topic, size, offset, escape_topic))

template.render("topic.html", { posts = result[1], topic = topic, cur_page = page, sum_page = math.ceil(result[2][1].count / size) })
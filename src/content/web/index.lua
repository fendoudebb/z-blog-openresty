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

local sql = "select id, title, description, pv, like_count, comment_count, topics, to_char(create_ts, 'YYYY-MM-DD') as create_ts from post where post_status = 0 order by create_ts desc limit %d offset %d"

local result = db.query(string.format(sql, size, offset))

local memory = ngx.shared.memory
-- TODO 新增文章时记得重新设置
local online_post_count = memory:get("online_post_count")
if not online_post_count then
    online_post_count = db.query("select count(*) as count from post where post_status = 0")[1].count
    memory:set("online_post_count", online_post_count)
end

template.render("index.html", { posts = result, cur_page = page, sum_page = math.floor(online_post_count / size) })
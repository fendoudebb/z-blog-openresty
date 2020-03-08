local template = require "resty.template"
local db = require "module.db"

-- to_char(post_ts, 'YYYY-MM-DD HH24:MI:SS') as post_ts
-- 判断json对象数组中是否包含，post_like 为空时是null，不为空时是true/false
-- select * , post_like @> '[{"ip":"117.187.27.178"}]' from post;

local sql = [[
select id, title, pv from post where post_status = 0 order by random() limit 10;
select
id, title, keywords, description, topics, content_html, word_count, post_status,
pv, like_count, comment_count, comment_status, to_char(create_ts, 'YYYY-MM-DD') as create_ts, post_comment,
post_like @> '[{"ip":"%s"}]'::jsonb as is_liked
from post where id = %d and post_status = 0
]]

local result = db.query(string.format(sql, ngx.ctx.client_ip, ngx.var[1]))

if result[2][1] == nil then
    -- TODO 还未统计record_invalid_request
    ngx.exit(ngx.HTTP_NOT_FOUND)
end

local post = result[2][1]

post.random_post = result[1]

--table转字符串
--table.concat(post.topics, ',')

-- 统计用
ngx.ctx.post_id = post.id
ngx.ctx.post = post

template.render("post.html", {post = post})
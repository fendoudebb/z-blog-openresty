local template = require "resty.template"
local db = require "module.db"

-- to_char(post_ts, 'YYYY-MM-DD HH24:MI:SS') as post_ts
-- 判断json对象数组中是否包含，post_like 为空时是null，不为空时是true/false
-- select * , post_like @> '[{"ip":"127.0.0.1"}]' from post;

local sql = [[
select id, title, pv from post where post_status=0 order by random() limit 10;
select
id, title, keywords, description, topics, content_html, word_count, post_status,
pv, like_count, comment_count, comment_status, to_char(create_ts, 'YYYY-MM-DD') as create_ts, post_comment,
post_like @> '[{"ip":"%s"}]'::jsonb as is_liked
from post where id=%d
]]

local result = db.query(string.format(sql, ngx.ctx.client_ip, ngx.var[1]))

local post = result[2][1]

if not post or post.post_status ~= 0 then
    ngx.status = ngx.HTTP_NOT_FOUND
    return template.render("404.html")
end

post.random_post = result[1]

--table转字符串
--table.concat(post.topics, ',')

template.render("post.html", {post = post})

-- 统计stat.lua用
ngx.ctx.post_id = post.id
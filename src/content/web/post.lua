ngx.ctx.post_id = ngx.var[1]

-- to_char(post_ts, 'YYYY-MM-DD HH24:MI:SS') as post_ts
local result = util.query_db([[
select id, title, pv from post where post_status = 0 order by random() limit 10;
select
title, keywords, description, topics, content_html, word_count, post_status,
pv, like_count, comment_count, comment_status, to_char(post_ts, 'YYYY-MM-DD') as post_ts, post_comment, post_like::text
from post where id = ]] .. ngx.ctx.post_id)

if result[2][1] == nil then
    ngx.exit(ngx.HTTP_NOT_FOUND)
end

local post = result[2][1]

if post.post_status ~= 0 then
    ngx.exit(ngx.HTTP_NOT_FOUND)
end

post.random_post = result[1]

--table转字符串
--table.concat(post.topics, ',')

if string.find(post.post_like, util.get_client_ip()) ~= nil then
    post.is_liked = true
end

ngx.ctx.post = post

template.render("post.html")
-- to_char(post_ts, 'YYYY-MM-DD HH24:MI:SS') as post_ts
-- select * , post_like @> '[{"ip":"117.187.27.178"}]'::jsonb from post; 判断json对象数组中是否包含
local result = db.query([[
select id, title, pv from post where post_status = 0 order by random() limit 10;
select
id, title, keywords, description, topics, content_html, word_count, post_status,
pv, like_count, comment_count, comment_status, to_char(create_ts, 'YYYY-MM-DD') as create_ts, post_comment,
post_like @> '[{"ip":"]] .. ngx.ctx.client_ip .. [["}]'::jsonb as is_liked
from post where id = ]] .. ngx.var[1])

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

template.render("post.html", {post = post})
local post_id = ngx.ctx.body_data.post_id

if type(post_id) ~= "number" then
    ngx.log(ngx.ERR, "[post like] post_id type ~= number#", type(post_id))
    return req.bad_request()
end

local referer = ngx.var.http_referer

local valid_referer = "/p/" .. post_id .. ".html"

req.valid_http_referer(referer, valid_referer)

--select
--id, title, keywords, description, topics, content_html, word_count, post_status,
--pv, like_count, comment_count, comment_status, to_char(create_ts, 'YYYY-MM-DD') as create_ts, post_comment,
--post_like @> '[{"ip":"]] .. ngx.ctx.client_ip .. [["}]'::jsonb as is_liked
--from post where id = ]] .. ngx.var[1]

local select_sql = [[
select
id, title, keywords, description, topics, content_html, word_count, post_status,
pv, like_count, comment_count, comment_status, to_char(create_ts, 'YYYY-MM-DD') as create_ts, post_comment,
post_like @> '[{"ip":"%s"}]'::jsonb as is_liked
from post where id = %d
]]
local result = db.query(string.format(select_sql, ngx.ctx.client_ip, post_id))

local post = result[1]

if post == nil then
    return ngx.say(json.encode(const.post_not_exist))
end

if post.is_liked then
    return ngx.say(json.encode(const.post_like_already))
end

local data = json.encode({
    ip = ngx.ctx.client_ip,
    likeTime = ngx.time()
})

local update_sql = [[
update post set post_like =
(
    case when post_like is not null then post_like || '%s'
    else '[%s]'
    end
), like_count = like_count + 1
where id = %d and post_like @> '[{"ip":"%s"}]' is false;
]]

db.query(string.format(update_sql, data, data, post_id, ngx.ctx.client_ip))

ngx.say(json.encode(const.ok))
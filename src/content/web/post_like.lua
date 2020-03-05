local post_id = ngx.ctx.body_data.post_id

if type(post_id) ~= 'number' then
    ngx.log(ngx.ERR, "[post like] post_id type ~= number#", type(post_id))
    return req.bad_request()
end

local referer = ngx.var.http_referer or 'http://localhost/p/'..post_id..'.html' -- TODO 便于测试，上线前删除
if not referer then
    ngx.log(ngx.ERR, "[post like] referer is nil, post_id#", post_id)
    return req.bad_request()
end

local valid_referer = "/p/" .. post_id .. ".html"

local captures, err = ngx.re.match(referer, valid_referer)

if not captures then
    ngx.log(ngx.ERR, "[post like] referer#", referer, " is invalid#", err)
    return req.bad_request()
end

--select
--id, title, keywords, description, topics, content_html, word_count, post_status,
--pv, like_count, comment_count, comment_status, to_char(create_ts, 'YYYY-MM-DD') as create_ts, post_comment,
--post_like @> '[{"ip":"]] .. ngx.ctx.client_ip .. [["}]'::jsonb as is_liked
--from post where id = ]] .. ngx.var[1]

local result = db.query([[
select
id, title, keywords, description, topics, content_html, word_count, post_status,
pv, like_count, comment_count, comment_status, to_char(create_ts, 'YYYY-MM-DD') as create_ts, post_comment,
post_like @> '[{"ip":"]] .. ngx.ctx.client_ip .. [["}]'::jsonb as is_liked
from post where id =
]] .. post_id)

local post = result[1]

if post == nil then
    local res = {
        code = const.post_not_exist.code,
        msg = const.post_not_exist.msg
    }
    return ngx.say(json.encode(res))
end

if post.is_liked then
    local res = {
        code = const.post_like_already.code,
        msg = const.post_like_already.msg
    }
    return ngx.say(json.encode(res))
end


local data = {
    {
        ip = ngx.ctx.client_ip,
        likeTime = ngx.time()
    }
}
-- TODO插入数据库
ngx.log(ngx.ERR, "post data like#", json.encode(data))
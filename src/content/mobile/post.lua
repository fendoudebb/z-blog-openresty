local json = require "cjson.safe"
local const = require "module.const"
local db = require "module.db"
local req = require "module.req"

local sql = [[
select id as "postId", title, topics, content_html as "contentHtml", word_count as "postWordCount", post_status,
pv, like_count as "likeCount", comment_count as "commentCount", comment_status as "commentStatus", trunc(EXTRACT(EPOCH FROM (create_ts)) * 1000) as "postTime"
from post where id=%d;
]]

sql = string.format(sql, ngx.var[1])

ngx.log(ngx.ERR, "sql#", sql)

local result = db.query(sql)

local post = result[1]

if not post or post.post_status ~= 0 then
    return req.request_error(ngx.HTTP_NOT_FOUND, const.post_not_exist())
end

local res = const.ok({post = post})

ngx.say(json.encode(res))

-- 统计stat.lua用
ngx.ctx.post_id = post.id
ngx.ctx.is_mini_program = true
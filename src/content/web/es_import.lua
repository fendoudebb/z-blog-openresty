local json = require "cjson.safe"
local http = require "resty.http"
local db = require "module.db"
local html = require "module.html"

local sql = "select id, title, topics, post_status, content_html, to_char(create_ts, 'YYYY-MM-DD') as create_ts from post"

local result = db.query(sql)

local httpc = http.new()

for _, post in ipairs(result) do
    local param = {
        postId = post.id,
        postTime = post.create_ts,
        offline = post.post_status ~= 0,
        topics = post.topics,
        title = post.title,
        content = html.strip_tags(post.content_html)
    }
    local res, err = httpc:request_uri("http://127.0.0.1:9200/post/_doc/" .. post.id, {
        method = "PUT",
        body = json.encode(param),
        headers = {
            ["Content-Type"] = "application/json",
        },
        keepalive_timeout = 2000 -- 毫秒
    })

    if not res then
        ngx.log(ngx.ERR, "put es error#", err)
    else
        ngx.log(ngx.ERR, "put es success#", res.body)
    end
end

ngx.say("ok")
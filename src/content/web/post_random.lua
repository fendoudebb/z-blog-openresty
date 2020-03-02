
local result = db.query([[
select id as "postId", title, pv from post where post_status = 0 order by random() limit 10
]])
ngx.log(ngx.ERR, json.encode(result))
local res = {
    code = 200,
    msg = '请求成功',
    data = {
        post = result
    }
}
ngx.say(json.encode(res))

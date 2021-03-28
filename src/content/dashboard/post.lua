local json = require "cjson.safe"
local const = require "module.const"
local db = require "module.db"
local req = require "module.req"

local req_url = ngx.var[1]

local sql_args = req.get_page_size(ngx.ctx.body_data)

if req_url == "list" then
    local post_id = ngx.ctx.body_data.post_id
    local rank_type = ngx.ctx.body_data.rank_type

    local sql = [[
        select count(*) as count from post %s;
        select id, title, pv, post_status, prop, like_count, comment_count, topics, to_char(create_ts, 'YYYY-MM-DD hh24:MI:ss') as create_ts from post %s order by %s desc limit %d offset %d
    ]]

    local where_cause = ""

    local order_cause = "id"

    if type(post_id) == "number" then
        where_cause = "where id=" .. post_id
    else
        if rank_type == "pv" then
            where_cause = "where pv>0"
            order_cause = "(pv,id)"
        elseif rank_type == "comment_count" then
            where_cause = "where comment_count>0"
            order_cause = "(comment_count,id)"
        elseif rank_type == "like_count" then
            where_cause = "where like_count>0"
            order_cause = "(like_count,id)"
        end
    end

    local result = db.query(string.format(sql, where_cause, where_cause, order_cause, sql_args.limit, sql_args.offset))

    ngx.say(json.encode(const.ok({
        count = result[1][1].count,
        posts = result[2]
    })))
elseif req_url == "audit" then
    local id = ngx.ctx.body_data.id
    local status = ngx.ctx.body_data.status

    if type(id) ~= "number" or type(status) ~= "number" or status > 1 then
        return req.bad_request()
    end

    local sql = [[
        update post set post_status=%d where id=%d
    ]]

    local update_result = db.query(string.format(sql, status, id))

    if update_result.affected_rows < 1 then
        ngx.say(json.encode(const.fail()))
    else
        ngx.ctx.post_id = id
        ngx.say(json.encode(const.ok()))
    end
elseif req_url == "info" then
    local id = ngx.ctx.body_data.id

    if type(id) ~= "number" or id < 1 then
        return req.bad_request()
    end

    local sql = [[
        select id, title, content, post_status, prop, topics from post where id=%d limit 1
    ]]

    local result = db.query(string.format(sql, id))

    ngx.say(json.encode(const.ok(result[1])))

elseif req_url == "publish" then
    local id = ngx.ctx.body_data.id
    local title = ngx.ctx.body_data.title
    local topics = ngx.ctx.body_data.topics
    local content = ngx.ctx.body_data.content
    local content_html = ngx.ctx.body_data.content_html
    local word_count = ngx.ctx.body_data.word_count
    local prop = ngx.ctx.body_data.prop
    local post_status = ngx.ctx.body_data.post_status
    local description = ngx.ctx.body_data.description
    local keywords = ngx.ctx.body_data.keywords

    local sql

    if id then
        -- update
        if type(id) ~= "number" or id < 1 then
            return req.bad_request()
        end

        sql = [[
            update post set title=%s, description=%s, topics=%s, content=%s, content_html=%s, word_count=%d, prop=%d, post_status=%d, keywords=%s
            where id=%d
        ]]

        sql = string.format(sql, db.quote(title), db.quote(description), db.encode_arr(topics), db.quote(content), db.quote(content_html), word_count, prop, post_status, db.quote(keywords), id)

    else
        -- insert

        sql = [[
            insert into post(id, uid, title, description, topics, content, content_html, word_count, prop, post_status, keywords)
            values((select max(id) from post) + 1, %d, %s, %s, %s, %s, %s, %d, %d, %d, %s) returning id
        ]]

        sql = string.format(sql, ngx.ctx.user_info.id, db.quote(title), db.quote(description), db.encode_arr(topics), db.quote(content), db.quote(content_html), word_count, prop, post_status, db.quote(keywords))

    end

    local result = db.query(sql)

    if result and result.affected_rows > 0 then
        local post_id
        if id then
            post_id = id
        else
            post_id = result[1].id
        end
        ngx.ctx.post_id = post_id
        ngx.say(json.encode(const.ok({
            id = post_id
        })))
    else
        ngx.say(json.encode(const.fail()))
    end

    --local pure_text = html.strip_tags(content_html)
    --local pure_text_count = utf8.len(pure_text)
    --local word_count = #(pure_text):gsub('[\128-\191]', '')

    --ngx.log(ngx.ERR, word_count)
    --ngx.log(ngx.ERR, #("我是谁123我abc,，。\ta"):gsub('[\128-\191]', ''))

end


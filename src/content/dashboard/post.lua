local json = require "cjson.safe"
local const = require "module.const"
local db = require "module.db"
local req = require "module.req"

local req_url = ngx.var[1]

ngx.log(ngx.ERR, json.encode(req_url))

local sql_args = req.get_page_size(ngx.ctx.body_data)

if req_url == "list" then
    local post_id = ngx.ctx.body_data.post_id
    local rank_type = ngx.ctx.body_data.rank_type

    local sql = [[
        select count(*) as count from post %s;
        select id, title, pv, post_status, prop, like_count, comment_count, topics, to_char(create_ts, 'YYYY-MM-DD hh24:MI:ss') as create_ts from post %s order by %s desc limit %d offset %d
    ]]

    local where_cause = ""

    if type(post_id) == "number" then
        where_cause = "where id=" .. post_id
    end

    local order_cause = ""

    if rank_type == nil then
        order_cause = "id"
    elseif rank_type == "pv" then
        order_cause = "pv"
    elseif rank_type == "comment_count" then
        order_cause = "comment_count"
    elseif rank_type == "like_count" then
        order_cause = "like_count"
    else
        order_cause = "id"
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
        ngx.say(json.encode(const.ok()))
    end

end


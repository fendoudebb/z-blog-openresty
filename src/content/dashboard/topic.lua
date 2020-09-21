local json = require "cjson.safe"
local const = require "module.const"
local db = require "module.db"
local req = require "module.req"

local req_url = ngx.var[1]

local sql
if req_url == "list" then
    local where_cause = ""

    local name = ngx.ctx.body_data.name
    if type(name) == "string" then
        where_cause = "where name=" .. db.quote(name)
    end

    local sql_args = req.get_page_size(ngx.ctx.body_data)
    sql = [[
    select count(*) from topic %s;
    select id, name, sort, to_char(create_ts, 'YYYY-MM-DD hh24:MI:ss') as create_ts, to_char(update_ts, 'YYYY-MM-DD hh24:MI:ss') as update_ts from topic %s order by sort limit %d offset %d
    ]]
    sql = string.format(sql, where_cause, where_cause, sql_args.limit, sql_args.offset)
    local result = db.query(sql)
    ngx.say(json.encode(const.ok({
        count = result[1][1].count,
        topics = result[2]
    })))
else
    local id = ngx.ctx.body_data.id
    local name = db.quote(ngx.ctx.body_data.name)
    if type(id) == "number" then
        local sort = ngx.ctx.body_data.sort
        if type(sort) ~= "number" then
            return req.bad_request()
        end
        -- 改
        sql = "update topic set name=%s, sort=%d, update_ts=current_timestamp where id=%d"
        sql = string.format(sql, name, sort, id)
    else
        -- 增
        local result = db.query("select id from topic where name=" .. name)
        if result[1] and result[1].id then
            return ngx.say(json.encode(const.topic_repeated()))
        end
        sql = "insert into topic(name, sort) values(%s, COALESCE((select max(sort) from topic), 0)+1)"
        sql = string.format(sql, name)
    end
    db.query(sql)
    ngx.say(json.encode(const.ok()))
end

local json = require "cjson.safe"
local const = require "module.const"
local db = require "module.db"
local req = require "module.req"

local req_url = ngx.var[1]

local sql
if req_url == "list" then
    local where_cause = ""

    local username = ngx.ctx.body_data.username
    if type(username) == "string" then
        where_cause = "where username=" .. db.quote(username)
    end

    local sql_args = req.get_page_size(ngx.ctx.body_data)
    sql = [[
    select count(*) from dashboard_user %s;
    select id, username, roles, status, to_char(create_ts, 'YYYY-MM-DD hh24:MI:ss') as create_ts, to_char(update_ts, 'YYYY-MM-DD hh24:MI:ss') as update_ts from dashboard_user %s order by id limit %d offset %d
    ]]
    sql = string.format(sql, where_cause, where_cause, sql_args.limit, sql_args.offset)
    local result = db.query(sql)
    ngx.say(json.encode(const.ok({
        count = result[1][1].count,
        dashboard_users = result[2]
    })))
else
    local id = ngx.ctx.body_data.id
    local username = db.quote(ngx.ctx.body_data.username)
    local roles_table = ngx.ctx.body_data.roles
    if not roles_table then
        return req.bad_request()
    end

    local roles = "array[%s]"

    local roles_str = ""
    for _, v in ipairs(ngx.ctx.body_data.roles) do
        roles_str = roles_str ..db.quote(v)
    end

    roles = string.format(roles, roles_str)

    local result = db.query("select id from dashboard_user where username=" .. username)
    if result[1] and result[1].id and result[1].id ~= id then
        return ngx.say(json.encode(const.dashboard_user_repeated()))
    end

    if type(id) == "number" then
        -- 改
        local status = ngx.ctx.body_data.status
        if type(status) ~= "number" then
            return req.bad_request()
        end
        sql = "update dashboard_user set username=%s, roles=%s, status=%d, update_ts=current_timestamp where id=%d"
        sql = string.format(sql, username, roles, status, id)
    else
        -- 增
        local password = db.quote(ngx.ctx.body_data.password)
        sql = "insert into dashboard_user(username, password, roles) values(%s, %s, %s)"
        sql = string.format(sql, username, password, roles)
    end
    db.query(sql)
    ngx.say(json.encode(const.ok()))
end

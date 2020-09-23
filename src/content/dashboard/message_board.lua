local json = require "cjson.safe"
local const = require "module.const"
local db = require "module.db"
local req = require "module.req"
local util = require "module.util"

local req_url = ngx.var[1]

local sql
if req_url == "list" then
    local sql_args = req.get_page_size(ngx.ctx.body_data)
    sql = [[
    select count(*) from message_board where root_id is null;
    select id, nickname, content, floor, like_count, reply_count, status, ua, os, browser, ip_id, to_char(create_ts, 'YYYY-MM-DD hh24:MI:ss') as create_ts from message_board where root_id is null order by id desc limit %d offset %d
    ]]
    sql = string.format(sql, sql_args.limit, sql_args.offset)
    local result = db.query(sql)
    ngx.say(json.encode(const.ok({
        count = result[1][1].count,
        message_board = result[2]
    })))
elseif req_url == "audit" then
    -- 上下线
    local id = ngx.ctx.body_data.id
    local status = ngx.ctx.body_data.status
    if type(id) ~= "number" or type(status) ~= "number" then
        return req.bad_request()
    end
    sql = "update message_board set status=%d, update_ts=current_timestamp where id=%d"
    sql = string.format(sql, status, id)
    db.query(sql)
    ngx.say(json.encode(const.ok()))
elseif req_url == "reply" then
    -- 回复
    local reply_id = ngx.ctx.body_data.reply_id
    local content = db.quote(ngx.ctx.body_data.content)
    --if id and id ~= ngx.null then -- 如果前端传null过来需要判断是否等于ngx.null
    if type(reply_id) ~= "number" then
        return req.bad_request()
    end

    local result = db.query("select id, root_id from message_board where id=" .. reply_id)[1]
    if not result or not result.id then
        return ngx.say(json.encode(const.message_board_not_exist()))
    end

    -- root_id不存在则等于id
    local root_id = result.root_id or result.id

    local client_ip = req.get_ip_from_headers(ngx.req.get_headers())
    local ip_id = util.query_ip(client_ip).id
    local user_agent = ngx.var.http_user_agent
    local ua = req.parse_ua(user_agent)
    local os = db.quote(ua.os)
    local browser = db.quote(ua.name)

    sql = [[
    insert into message_board(nickname, content, ua, os, browser, ip_id, reply_id, root_id) values('作者回复', %s, %s, %s, %s, %s, %s, %s);
    update message_board set reply_count=reply_count+1, update_ts=current_timestamp where id = %d
    ]]
    sql = string.format(sql, content, db.quote(user_agent), os, browser, ip_id, reply_id, root_id, reply_id)
    db.query(sql)

    ngx.say(json.encode(const.ok()))
else
    -- 回复列表
    local id = ngx.ctx.body_data.id
    if type(id) ~= "number" then
        return req.bad_request()
    end

    local sql_args = req.get_page_size(ngx.ctx.body_data)
    sql = [[
    select count(*) from message_board where root_id=%d;
    select id, nickname, content, floor, like_count, reply_count, status, ua, os, browser, ip_id, to_char(create_ts, 'YYYY-MM-DD hh24:MI:ss') as create_ts from message_board where root_id=%d order by id desc limit %d offset %d
    ]]
    sql = string.format(sql, id, id, sql_args.limit, sql_args.offset)
    local result = db.query(sql)
    ngx.say(json.encode(const.ok({
        count = result[1][1].count,
        message_board = result[2]
    })))
end

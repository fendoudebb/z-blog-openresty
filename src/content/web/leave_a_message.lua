local json = require "cjson.safe"
local const = require "module.const"
local db = require "module.db"
local req = require "module.req"
local util = require "module.util"

local nickname = ngx.ctx.body_data.nickname
local content = ngx.ctx.body_data.content
local reply_id = ngx.ctx.body_data.reply_id
local client_ip = ngx.ctx.client_ip
local ua = ngx.ctx.ua;

local referer = ngx.var.http_referer
local valid_referer = "/message-board.html"
local valid_result = req.valid_http_referer(referer, valid_referer)
if not valid_result then
    return req.bad_request()
end

if not nickname then
    ngx.log(ngx.ERR, "[message board] nickname is nil, ip#", client_ip)
    return req.bad_request()
end

if not content then
    ngx.log(ngx.ERR, "[message board] content is nil, ip#", client_ip)
    return req.bad_request()
end

local sql

if reply_id then
    if type(reply_id) ~= "number" then
        return req.bad_request()
    end

    local result = db.query("select id, root_id from message_board where id=" .. reply_id)[1]
    if not result or not result.id then
        return ngx.say(json.encode(const.message_board_not_exist()))
    end

    local root_id = result.root_id or result.id

    local ip_id = util.query_ip(client_ip).id

    sql = [[
    insert into message_board(nickname, content, ua, os, browser, ip_id, reply_id, root_id) values(%s, %s, %s, %s, %s, %s, %s, %s);
    update message_board set reply_count=reply_count+1, update_ts=current_timestamp where id = %d
    ]]
    sql = string.format(sql, db.quote(nickname), db.quote(content), db.quote(ngx.var.http_user_agent), db.quote(ua.os), db.quote(ua.name), ip_id, reply_id, root_id, reply_id)
    ngx.log(ngx.ERR, sql)
else
    sql = [[
        insert into message_board(nickname, content, floor, ip_id, ua, os, browser) values(
        %s, %s, COALESCE((select max(floor) from message_board), 0)+1, %s, %s, %s, %s
        )
    ]]

    sql = string.format(sql, db.quote(nickname), db.quote(content), util.query_ip(client_ip).id, db.quote(ngx.var.http_user_agent), db.quote(ua.os), db.quote(ua.name))
end

db.query(sql)

local memory = ngx.shared.memory
memory:delete("message_board_count")

ngx.say(json.encode(const.ok()))
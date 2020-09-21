local json = require "cjson.safe"
local const = require "module.const"
local db = require "module.db"
local req = require "module.req"
local util = require "module.util"

local nickname = ngx.ctx.body_data.nickname
local content = ngx.ctx.body_data.content
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

local sql = [[
insert into message_board(nickname, content, floor, ip_id, ua, os, browser) values(
%s, %s, COALESCE((select max(floor) from message_board), 0)+1, %s, %s, '%s', '%s'
)
]]

local insert_result = db.query(string.format(sql, db.quote(nickname), db.quote(content), util.query_ip(client_ip).id, db.quote(ngx.var.http_user_agent), ua.os, ua.name))

if insert_result.affected_rows < 1 then
    ngx.say(json.encode(const.fail()))
else
    local memory = ngx.shared.memory
    memory:delete("message_board_count")
    ngx.say(json.encode(const.ok()))
end
local json = require "cjson.safe"
local const = require "module.const"
local req = require "module.req"
local util = require "module.util"

local query_ip = ngx.ctx.body_data.ip

local referer = ngx.var.http_referer
local valid_referer = "/tool/ip.html"
local valid_result = req.valid_http_referer(referer, valid_referer)
if not valid_result then
    return req.bad_request()
end

if type(query_ip) ~= "string" then
    ngx.log(ngx.ERR, "[query] ip type ~= string#", type(query_ip))
    return req.bad_request()
end

local address = util.query_ip(query_ip);

if address then
    ngx.say(json.encode(const.ok(address)))
else
    ngx.say(json.encode(const.query_ip_fail()))
end

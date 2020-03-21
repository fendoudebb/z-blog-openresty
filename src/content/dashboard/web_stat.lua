local json = require "cjson.safe"
local const = require "module.const"

local memory = ngx.shared.memory
local web_stat = memory:get("web_stat")
if web_stat ~= nil then
    ngx.say(json.encode(const.ok(json.decode(web_stat))))
else
    ngx.say(json.encode(const.fail()))
end
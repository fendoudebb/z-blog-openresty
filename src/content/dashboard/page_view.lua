local json = require "cjson.safe"
local const = require "module.const"
local db = require "module.db"
local req = require "module.req"

local req_url = ngx.var[1]

local sql_args = req.get_page_size(ngx.ctx.body_data)

local sql = [[
    select count(*) from %s;
    with t as
    (
    select id, url, req_method, req_param, ip_id, ua, browser, browser_platform, browser_version, browser_vendor, os, os_version, referer, cost_time, to_char(create_ts, 'YYYY-MM-DD hh24:MI:ss') as create_ts from %s order by id desc limit %d offset %d
    )
    select t.*, t2.ip, t2.address from t left join
    (select id, ip, country || COALESCE(region,'') || COALESCE(city,'') || COALESCE(isp,'') as address from ip_pool t1 where t1.id in (select ip_id from t)) t2 on t.ip_id = t2.id;
]]
if req_url == "list" then
    --select id, url, req_method, req_param, ip_id, ua, browser, browser_platform, browser_version, browser_vendor, os, os_version, referer, cost_time, to_char(create_ts, 'YYYY-MM-DD hh24:MI:ss') as create_ts from record_page_view order by id desc limit %d offset %d
    sql = string.format(sql, "record_page_view", "record_page_view", sql_args.limit, sql_args.offset)

elseif req_url == "invalid-list" then
    sql = string.format(sql, "record_invalid_request", "record_invalid_request", sql_args.limit, sql_args.offset)
end

local result = db.query(sql)

ngx.say(json.encode(const.ok({
    count = result[1][1].count,
    page_view = result[2]
})))

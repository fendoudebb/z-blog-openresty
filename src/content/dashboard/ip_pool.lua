local json = require "cjson.safe"
local const = require "module.const"
local db = require "module.db"
local req = require "module.req"


local req_url = ngx.var[1]

local sql_args = req.get_page_size(ngx.ctx.body_data)

if req_url == "list" then
    local ip = ngx.ctx.body_data.ip

    local sql = [[
        select count(*) as count from ip_pool %s;
        select id, ip::text, country, region, city, isp, country_id, region_id, city_id, isp_id, to_char(create_ts, 'YYYY-MM-DD hh24:MI:ss') as create_ts from ip_pool %s order by id desc limit %d offset %d
    ]]

    local where_cause = ""

    if type(ip) == "string" then
        where_cause = "where ip=" .. db.quote(ip) .. "::inet"
    end

    local result = db.query(string.format(sql, where_cause, where_cause, sql_args.limit, sql_args.offset))

    ngx.say(json.encode(const.ok({
        count = result[1][1].count,
        ip_pool = result[2]
    })))
elseif req_url == "unknown-list" then
    local sql = [[
        select count(*) as count from ip_unknown;
        select ip, to_char(create_ts, 'YYYY-MM-DD hh24:MI:ss') as create_ts, to_char(create_ts, 'YYYY-MM-DD hh24:MI:ss') as update_ts from ip_unknown order by create_ts desc limit %d offset %d
    ]]
    local result = db.query(string.format(sql, sql_args.limit, sql_args.offset))

    ngx.say(json.encode(const.ok({
        count = result[1][1].count,
        ip_unknown = result[2]
    })))
end


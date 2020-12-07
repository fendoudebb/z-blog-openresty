local json = require "cjson.safe"
local const = require "module.const"
local db = require "module.db"
local req = require "module.req"

local sql_args = req.get_page_size(ngx.ctx.body_data)

local sql = [[
    select count(*) from %s;
    with t as
    (
    select id, keywords, took, hits, ip_id, referer, browser, os, to_char(create_ts, 'YYYY-MM-DD hh24:MI:ss') as create_ts from %s order by id desc limit %d offset %d
    )
    select t.*, t2.ip, t2.address from t left join
    (select id, ip, country || COALESCE(region,'') || COALESCE(city,'') || COALESCE(isp,'') as address from ip_pool t1 where t1.id in (select ip_id from t)) t2 on t.ip_id = t2.id;
]]

sql = string.format(sql, "record_search", "record_search", sql_args.limit, sql_args.offset)

local result = db.query(sql)

ngx.say(json.encode(const.ok({
    count = result[1][1].count,
    search_record = result[2]
})))

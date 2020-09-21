local json = require "cjson.safe"
local const = require "module.const"
local db = require "module.db"
local req = require "module.req"

local req_url = ngx.var[1]

local sql
if req_url == "list" then
    local sql_args = req.get_page_size(ngx.ctx.body_data)
    sql = [[
    select count(*) from link;
    select id, sort, website, url, webmaster, webmaster_email, status, to_char(create_ts, 'YYYY-MM-DD hh24:MI:ss') as create_ts, to_char(update_ts, 'YYYY-MM-DD hh24:MI:ss') as update_ts from link order by sort limit %d offset %d
    ]]
    sql = string.format(sql, sql_args.limit, sql_args.offset)
    local result = db.query(sql)
    ngx.say(json.encode(const.ok({
        count = result[1][1].count,
        links = result[2]
    })))
elseif req_url == "audit" then
    local id = ngx.ctx.body_data.id
    local status = ngx.ctx.body_data.status
    if type(id) ~= "number" or type(status) ~= "number" then
        return req.bad_request()
    end
    sql = "update link set status=%d, update_ts=current_timestamp where id=%d"
    sql = string.format(sql, status, id)
    db.query(sql)
    ngx.say(json.encode(const.ok()))
else
    local id = ngx.ctx.body_data.id
    local website = db.quote(ngx.ctx.body_data.website)
    local webmaster = db.quote(ngx.ctx.body_data.webmaster)
    local webmaster_email = db.quote(ngx.ctx.body_data.webmaster_email)
    local url = db.quote(ngx.ctx.body_data.url)
    --if id and id ~= ngx.null then -- 如果前端传null过来需要判断是否等于ngx.null
    if type(id) == "number" then
        local sort = ngx.ctx.body_data.sort
        if type(sort) ~= "number" then
            return req.bad_request()
        end
        -- 改
        sql = "update link set website=%s, url=%s, webmaster=%s, webmaster_email=%s, sort=%d, update_ts=current_timestamp where id=%d"
        sql = string.format(sql, website, url, webmaster, webmaster_email, sort, id)
    else
        -- 增
        local result = db.query("select id from link where url=" .. url)
        if result[1] and result[1].id then
            return ngx.say(json.encode(const.link_repeated()))
        end
        sql = "insert into link(website, url, webmaster, webmaster_email, sort) values(%s, %s, %s, %s, COALESCE((select max(sort) from link), 0)+1)"
        sql = string.format(sql, website, url, webmaster, webmaster_email)
    end
    db.query(sql)
    ngx.say(json.encode(const.ok()))
end

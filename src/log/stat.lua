local json = require "cjson.safe"
local db = require "module.db"
local util = require "module.util"

local function record_visit_data(premature, record)
    if not premature then

        local address = util.query_ip(record.ip)
        local sql = [[
                insert into %s(url, req_method, req_param, ip, ip_address, ua, browser, browser_platform, browser_version, browser_vendor, os, os_version, referer, cost_time)
                values(%s, %d, %s, '%s', %s, %s, '%s', '%s', '%s', '%s', '%s', '%s', %s, %.2f)
        ]]
        if record.status == 200 then
            local captures = ngx.re.match(record.url, "/p/")
            if captures and record.post_id then
                db.query("update post set pv = pv + 1 where id = " .. record.post_id)
            end
            db.query(string.format(sql, "record_page_view", db.val_escape(record.url), record.req_method, db.val_escape(record.req_param), record.ip, db.val_escape(address), db.val_escape(record.ua), record.browser, record.browser_platform, record.browser_version, record.browser_vendor, record.os, record.os_version, db.val_escape(record.referer), record.cost_time))
        else
            -- 错误统计
            db.query(string.format(sql, "record_invalid_request", db.val_escape(record.url), record.req_method, db.val_escape(record.req_param), record.ip, db.val_escape(address), db.val_escape(record.ua), record.browser, record.browser_platform, record.browser_version, record.browser_vendor, record.os, record.os_version, db.val_escape(record.referer), record.cost_time))
        end
        -- TODO debug用
        ngx.log(ngx.ERR, json.encode(record))
    end
end

local ua = ngx.ctx.ua;

local request_method = ngx.var.request_method

local req_method
local req_param

if request_method == 'GET' then
    req_method = 0
    req_param = ngx.var.args
elseif request_method == 'POST' then
    req_method = 1
    req_param = ngx.req.get_body_data()
elseif request_method == 'PUT' then
    req_method = 2
elseif request_method == 'DELETE' then
    req_method = 3
elseif request_method == 'OPTION' then
    req_method = 4
else
    req_method = 5
end

local record = {
    url = ngx.var.uri,
    req_method = req_method,
    req_param = req_param,
    ip = ngx.ctx.client_ip,
    ua = ngx.var.http_user_agent,
    referer = ngx.var.http_referer,
    browser = ua.name,
    browser_platform = ua.category,
    browser_version = ua.version,
    browser_vendor = ua.vendor,
    os = ua.os,
    os_version = ua.os_version,
    status = ngx.status,
    cost_time = ngx.now() - ngx.req.start_time(),
    post_id = ngx.ctx.post_id
}

local ok, err = ngx.timer.at(0, record_visit_data, record)
if not ok then
    ngx.log(ngx.ERR, "failed to create record_visit_data timer#", json.encode(record), ", err#", err)
    return
end
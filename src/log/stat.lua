local function record_visit_data(premature, record)
    -- push the data uri, args, and status to the remote
    -- via ngx.socket.tcp or ngx.socket.udp
    -- (one may want to buffer the data in Lua a bit to
    -- save I/O operations)
    ngx.log(ngx.ERR,util.query_ip("112.65.145.179"))
    ngx.log(ngx.ERR, json.encode(record))
end

local ua = ngx.ctx.ua;

local record = {
    url = ngx.var.uri,
    req_method = ngx.var.request_method,
    req_param = ngx.var.args,
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
    cost_time = string.format("%.2f", ngx.now() - ngx.req.start_time()),
}

local ok, err = ngx.timer.at(0, record_visit_data, record)
if not ok then
    ngx.log(ngx.ERR, "failed to create record_visit_data timer: ", err)
    return
end
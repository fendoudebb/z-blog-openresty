local req_cost_time = ngx.now() - ngx.req.start_time()

local function record_visit_data(premature, uri, args, status, cost_time)
    -- push the data uri, args, and status to the remote
    -- via ngx.socket.tcp or ngx.socket.udp
    -- (one may want to buffer the data in Lua a bit to
    -- save I/O operations)
    ngx.log(ngx.ERR, "url=", uri, ", cost_time=", cost_time, ", status=", status)
end
local ok, err = ngx.timer.at(0, record_visit_data, ngx.var.uri, ngx.var.args, ngx.header.status, string.format("%.2f", req_cost_time))
if not ok then
    ngx.log(ngx.ERR, "failed to create record_visit_data timer: ", err)
    return
end
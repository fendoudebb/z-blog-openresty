local delay = 1000000  -- in seconds
local task = function(premature)
    if not premature then
        local running_count = ngx.timer.running_count()
        local pending_count = ngx.timer.pending_count()
        --util.query_ip('41.249.255.142')

        ngx.log(ngx.ERR, "test ngx.timer.every#running_count=", running_count, ", pending_count=", pending_count)
    end
end

if 0 == ngx.worker.id() then
    local ok, err = ngx.timer.every(delay, task)
    if not ok then
        ngx.log(ngx.ERR, "failed to create timer: ", err)
        return
    end
end

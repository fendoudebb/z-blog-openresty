local delay = 50000  -- in seconds
local task = function(premature)
    if not premature then

        local result = db.query("select ip from ip_unknown limit 1")[1]
        if result ~= nil then
            local address = util.query_ip(result.ip)
            if address ~= nil then
                db.query("delete from ip_unknown where ip = "..db.val_escape(result.ip))
            end
        end

        --local running_count = ngx.timer.running_count()
        --local pending_count = ngx.timer.pending_count()
        --ngx.log(ngx.ERR, "test ngx.timer.every#running_count=", running_count, ", pending_count=", pending_count)
    end
end

if 0 == ngx.worker.id() then
    local ok, err = ngx.timer.every(delay, task)
    if not ok then
        ngx.log(ngx.ERR, "failed to create timer: ", err)
        return
    end
end

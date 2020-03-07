local task_query_web_stat_delay = 1800  -- in seconds 30分钟
local task_query_unknown_ip_delay = 50000  -- TODO 正式环境需修改

local task_query_web_stat = function(premature)
    if not premature then
        util.query_web_stat()
    end
end

local task_query_unknown_ip = function(premature)
    if not premature then
        local result = db.query("select ip from ip_unknown limit 1")[1]
        if result ~= nil then
            local address = util.query_ip(result.ip)
            if address ~= nil then
                local sql = "delete from ip_unknown where ip = '%s'"
                db.query(string.format(sql, result.ip))
            end
        end
        --local running_count = ngx.timer.running_count()
        --local pending_count = ngx.timer.pending_count()
        --ngx.log(ngx.ERR, "test ngx.timer.every#running_count=", running_count, ", pending_count=", pending_count)
    end
end

if 0 == ngx.worker.id() then
    -- 启动时初始化
    ngx.timer.at(0, task_query_web_stat)

    local ok_task_query_web_stat, err_task_query_web_stat = ngx.timer.every(task_query_web_stat_delay, task_query_web_stat)
    if not ok_task_query_web_stat then
        ngx.log(ngx.ERR, "failed to create timer task_query_web_stat#", err_task_query_web_stat)
        return
    end

    local ok_task_query_unknown_ip, err_task_query_unknown_ip = ngx.timer.every(task_query_unknown_ip_delay, task_query_unknown_ip)
    if not ok_task_query_unknown_ip then
        ngx.log(ngx.ERR, "failed to create timer task_query_unknown_ip#", err_task_query_unknown_ip)
        return
    end

end

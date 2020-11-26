local util = require "module.util"

local function sync_es(premature, post_id)
    if not premature and post_id then
        -- index.html 需要用到 online_post_count
        local memory = ngx.shared.memory
        memory:delete("online_post_count")
        util.sync_es(post_id)
    end
end

local post_id = ngx.ctx.post_id;

local ok, err = ngx.timer.at(0, sync_es, post_id)
if not ok then
    ngx.log(ngx.ERR, "failed to create sync_es timer. post_id#", post_id, ", err#", err)
    return
end
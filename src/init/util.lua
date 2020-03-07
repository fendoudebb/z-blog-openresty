local _M = {}

function _M.query_ip(ip)
    --local result = db.query("select country || COALESCE(region,'') || COALESCE(city,'') || COALESCE(isp,'') as address from ip_pool where ip = " .. db.val_escape(ip) .. "::inet limit 1")
    -- select concat('ab', null, 'cd') => abcd
    local select_sql = "select concat(country, region, city, isp) as address from ip_pool where ip = '%s'::inet limit 1"
    local result = db.query(string.format(select_sql, ip))
    local prop = result[1];
    -- 第一次查询ip未成功，但已经入库，prop虽然不等于nil，但prop.address还是为nil
    if prop ~= nil then
        return prop.address
    end

    local httpc = http.new()
    local res, err = httpc:request_uri('http://ip.taobao.com/service/getIpInfo.php?ip=' .. ip, {
        keepalive_timeout = 2000 -- 毫秒
    })

    if not res or res.status then
        if not res then
            ngx.log(ngx.ERR, "request ip taobao error#", err)
        else
            ngx.log(ngx.ERR, "request ip taobao header status=502")
        end
        -- insert on conflict do update 需设置唯一约束（主键也是唯一约束）
        local insert_sql = "insert into ip_unknown(ip) values('%s') on conflict(ip) do update set update_ts = current_timestamp"
        db.query(string.format(insert_sql, ip))
        return nil
    end

    -- {"code":0,"data":{"ip":"41.249.255.142","country":"摩洛哥","area":"","region":"XX","city":"XX","county":"XX","isp":"XX","country_id":"MA","area_id":"","region_id":"xx","city_id":"xx","county_id":"xx","isp_id":"xx"}}
    ngx.log(ngx.ERR, 'request ip taobao success-body#', res.body)

    local json_data = json.decode(res.body).data

    if json_data.region == json_data.city then
        json_data.city = nil
    end

    if json_data.region == 'XX' then
        json_data.region = nil
    end

    if json_data.city == 'XX' then
        json_data.city = nil
    end

    if json_data.isp == 'XX' then
        json_data.isp = nil
    end

    if json_data.region_id == 'xx' then
        json_data.region_id = nil
    end

    if json_data.city_id == 'xx' then
        json_data.city_id = nil
    end

    if json_data.isp_id == 'xx' then
        json_data.isp_id = nil
    end

    local values = string.format("('%s'::inet, %s, %s, %s, %s, %s, %s, %s, %s)",
            ip,
            db.val_escape(json_data.country),
            db.val_escape(json_data.region),
            db.val_escape(json_data.city),
            db.val_escape(json_data.isp),
            db.val_escape(json_data.country_id),
            db.val_escape(json_data.region_id),
            db.val_escape(json_data.city_id),
            db.val_escape(json_data.isp_id)
    )

    local sql = "insert into ip_pool(ip, country, region, city, isp, country_id, region_id, city_id, isp_id) values" .. values
    db.query(sql)

    return json_data.country .. (json_data.region or "") .. (json_data.city or "") .. (json_data.isp or "")
end

--ngx.location.capture # API disabled in the context of ngx.timer
--function _M.query_ip(ip)
--    local res = ngx.location.capture('/http', {
--        vars = {
--            target = 'http://ip.taobao.com/service/getIpInfo.php?ip=' .. ip
--        }
--    })
--    ngx.log(ngx.ERR, res.status)
--    ngx.log(ngx.ERR, json.encode(res.body))
--end

function _M.query_web_stat()
    local start_query = ngx.now()
    local result = db.query([[
        select name from topic order by sort;
        select website, url from link where status = 0 order by sort;
        select count(*) from post where post_status = 0;
        select count(*) from ip_pool;
        select count(*) from record_page_view;
        select id, title, pv from post where post_status = 0 order by pv desc, create_ts desc limit 5;
        select id, title, like_count from post where post_status = 0 order by like_count desc, create_ts desc limit 5;
        select id, title, comment_count from post where post_status = 0 order by comment_count desc, create_ts desc limit 5;
    ]])

    local memory = ngx.shared.memory
    local success, err = memory:set("web_stat", json.encode(result))

    if not success then
        ngx.log(ngx.ERR, "set shm err#", err)
    else
        local capacity_bytes = memory:capacity()
        local free_bytes = memory:free_space()
        ngx.log(ngx.ERR, "shm capacity_bytes#" .. capacity_bytes / 1024 / 1024 .. "M; shm free_bytes#" .. free_bytes / 1024 / 1024 .. "M")
    end
    local cost_time = ngx.now() - start_query
    ngx.log(ngx.ERR, "query web_stat cost#" .. cost_time)
    return cost_time
end

return _M
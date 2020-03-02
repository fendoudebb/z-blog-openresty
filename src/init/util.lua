local _M = {}

local function filter_method(method, req_method)
    if method ~= req_method then
        ngx.log(ngx.ERR, "request_method=", req_method, ", non match=" .. method)
        ngx.exit(ngx.HTTP_NOT_ALLOWED)
    end
end

function _M.filter_non_get_method(req_method)
    filter_method('GET', req_method)
end

function _M.filter_non_post_method(req_method)
    filter_method('POST', req_method)
end

-- 返回woothee对象
-- {"name": "xxx", "category": "xxx", "os": "xxx", "version": "xxx", "vendor": "xxx"}
-- name => name of browser (or string like name of user-agent)
-- category => "pc", "smartphone", "mobilephone", "appliance", "crawler", "misc", "unknown"
-- os => os from user-agent, or carrier name of mobile phones
-- version => version of browser, or terminal type name of mobile phones
-- os_version => NT 10.0 .etc
-- 根据category是否为crawler来判断是否是爬虫
function _M.parse_ua(ua)
    return woothee.parse(ua)
end

-- 判断是否是爬虫，其实也是根据category是否为crawler来判断
--function _M.is_crawler(ua)
--    return woothee.is_crawler(ua)
--end

function _M.query_ip(ip)
    local result = db.query("select country || COALESCE(region,'') || COALESCE(city,'') || COALESCE(isp,'') as address from ip_pool where ip = " .. db.val_escape(ip) .. "::inet limit 1")
    local prop = result[1];
    -- 第一次查询ip未成功，但已经入库，prop虽然不等于nil，但prop.address还是为nil
    if prop ~= nil then
        return prop.address
    end

    local httpc = http.new()
    local res, err = httpc:request_uri('http://ip.taobao.com/service/getIpInfo.php?ip=' .. ip, {
        keepalive_timeout = 2000 -- 毫秒
    })

    if not res then
        ngx.log(ngx.ERR, "request ip taobao error#", err)
        db.query("insert into ip_pool(ip) values(" .. db.val_escape(ip) .. "::inet)")
        return ''
    end

    if res.status == 502 then
        ngx.log(ngx.ERR, "request ip taobao header status=502")
        db.query("insert into ip_pool(ip) values(" .. db.val_escape(ip) .. "::inet)")
        return ''
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

return _M
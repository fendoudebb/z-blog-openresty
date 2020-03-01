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

function _M.query_db(sql)
    local pg = pgmoon.new(config.pg_config())

    local success, err = pg:connect()
    if not success then
        ngx.log(ngx.ERR, 'connect pg error#', err)
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end

    -- num_queries, 几条sql语句执行
    local result, num_queries = pg:query(sql)

    pg:keepalive()

    return result
end

function _M.query_ip(ip)
    local httpc = http.new()
    local res, err = httpc:request_uri('http://ip.taobao.com/service/getIpInfo.php?ip=' .. ip, {
        keepalive_timeout = 2000 -- 毫秒
    })

    if not res or res.status == 502 then
        ngx.log(ngx.ERR, 'query_ip error or 502#', err, res.status)
        return err
    end
    -- TODO 解析json 现在还是text
    -- {"code":0,"data":{"ip":"41.249.255.142","country":"摩洛哥","area":"","region":"XX","city":"XX","county":"XX","isp":"XX","country_id":"MA","area_id":"","region_id":"xx","city_id":"xx","county_id":"xx","isp_id":"xx"}}
    ngx.log(ngx.ERR, 'query_ip success-body#', res.body)

end

return _M
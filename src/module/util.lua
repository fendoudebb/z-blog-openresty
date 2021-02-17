local json = require "cjson.safe"
local http = require "resty.http"
local db = require "module.db"
local html = require "module.html"

local _M = { _VERSION = "0.01"}

function _M.find(t, val)
    if type(t) ~= "table" then
        return false
    end

    for _, v in ipairs(t) do
        if v == val then
            return true
        end
    end
    return false
end

function _M.sync_es(post_id)

    local sql = "select id, title, topics, post_status, content_html, to_char(create_ts, 'YYYY-MM-DD') as create_ts from post where id=%d"

    local post = db.query(string.format(sql, post_id))[1]

    local param = {
        postId = post.id,
        postTime = post.create_ts,
        offline = post.post_status ~= 0,
        topics = post.topics,
        title = post.title,
        content = html.strip_tags(post.content_html)
    }

    local httpc = http.new()
    local res, err = httpc:request_uri("http://127.0.0.1:9200/post/_doc/" .. post.id, {
        method = "PUT",
        body = json.encode(param),
        headers = {
            ["Content-Type"] = "application/json",
        },
        keepalive_timeout = 2000 -- 毫秒
    })

    if not res then
        ngx.log(ngx.ERR, "sync es error#", err)
    else
        ngx.log(ngx.ERR, "sync es success#", res.body)
    end
end

function _M.query_ip(ip)
    --local result = db.query("select country || COALESCE(region,'') || COALESCE(city,'') || COALESCE(isp,'') as address from ip_pool where ip = " .. db.quote(ip) .. "::inet limit 1")
    -- select concat('ab', null, 'cd') => abcd
    local quote_ip = db.quote(ip)
    local select_sql = "select id, concat(country, region, city, isp) as address from ip_pool where ip=%s::inet limit 1"
    local prop = db.query(string.format(select_sql, quote_ip))[1];
    -- 第一次查询ip未成功，但已经入库，prop虽然不等于nil，但prop.address还是为nil
    -- Lua中除了nil和false是假，其他的都是真，空字符串也为真
    if prop ~= nil and prop.address ~= "" then
        return {
            id = prop.id,
            address = prop.address
        }
    end

    local httpc = http.new()
    local res, err = httpc:request_uri('http://ip.taobao.com/getIpInfo.php?ip=' .. ip, {
        keepalive_timeout = 2000 -- 毫秒
    })

    if (not res) or (res.status == 502) then
        if not res then
            ngx.log(ngx.ERR, "request ip taobao error#", err)
        else
            ngx.log(ngx.ERR, "request ip taobao header status=502")
        end
        -- insert on conflict do update 需设置唯一约束（主键也是唯一约束）
        local insert_sql = "insert into ip_unknown(ip) values(%s) on conflict(ip) do update set update_ts = current_timestamp"
        db.query(string.format(insert_sql, quote_ip))

        local id
        if not prop then
            local insert_ip_pool = "insert into ip_pool(ip) values(%s) returning id"
            -- {"1":{"id":54503},"affected_rows":1}
            -- 插入失败返回nil
            local result = db.query(string.format(insert_ip_pool, quote_ip))
            id = result[1].id
        else
            id = prop.id
        end
        return {
            id = id
        }
    else
        -- {"code":0,"data":{"ip":"111.225.148.62","country":"中国","area":"","region":"河北","city":"张家口","county":"XX","isp":"电信","country_id":"CN","area_id":"","region_id":"130000","city_id":"130700","county_id":"xx","isp_id":"100017"}}
        -- {"code":0,"data":{"ip":"41.249.255.142","country":"摩洛哥","area":"","region":"XX","city":"XX","county":"XX","isp":"XX","country_id":"MA","area_id":"","region_id":"xx","city_id":"xx","county_id":"xx","isp_id":"xx"}}
        -- {"code":"0","data":{"CITY_EN":"Shenzhen","QUERY_IP":"113.87.160.228","CITY_CODE":"440300","CITY_CN":"深圳","COUNTY_EN":"null","LONGITUDE":"","PROVINCE_CN":"广东","TZONE":"","PROVINCE_EN":"Guangdong","ISP_EN":"China-Telecom","AREA_CODE":"80","PROVINCE_CODE":"440000","ISP_CN":"电信","AREA_CN":"华南","COUNTRY_CN":"中国","AREA_EN":"HuaNan","COUNTRY_EN":"China","COUNTY_CN":"null","COUNTY_CODE":"null","ASN":"null","LATITUDE":"","COUNTRY_CODE":"CN","ISP_CODE":"100017"}}
        -- {"code":"0","data":{"CITY_EN":"xx","QUERY_IP":"46.219.210.147","CITY_CODE":"xx","CITY_CN":"XX","COUNTY_EN":"null","LONGITUDE":"","PROVINCE_CN":"XX","TZONE":"","PROVINCE_EN":"xx","ISP_EN":"xx","AREA_CODE":"xx","PROVINCE_CODE":"xx","ISP_CN":"XX","AREA_CN":"XX","COUNTRY_CN":"乌克兰","AREA_EN":"xx","COUNTRY_EN":"Ukraine","COUNTY_CN":"null","COUNTY_CODE":"null","ASN":"null","LATITUDE":"","COUNTRY_CODE":"UA","ISP_CODE":"xx"}}
        ngx.log(ngx.ERR, 'request ip taobao success-body#', res.body)

        local json_data = json.decode(res.body).data

        if json_data.PROVINCE_CN == json_data.CITY_CN then
            json_data.city = nil
        end

        if json_data.PROVINCE_CN == 'XX' then
            json_data.region = nil
        end

        if json_data.CITY_CN == 'XX' then
            json_data.CITY_CN = nil
        end

        if json_data.ISP_CN == 'XX' then
            json_data.ISP_CN = nil
        end

        if json_data.PROVINCE_CODE == 'xx' then
            json_data.region_id = nil
        end

        if json_data.CITY_CODE == 'xx' then
            json_data.CITY_CODE = nil
        end

        if json_data.ISP_CODE == 'xx' then
            json_data.isp_id = nil
        end

        local country = db.quote(json_data.COUNTRY_CN)
        local region = db.quote(json_data.PROVINCE_CN)
        local city = db.quote(json_data.CITY_CN)
        local isp = db.quote(json_data.ISP_CN)
        local country_id = db.quote(json_data.COUNTRY_CODE)
        local region_id = db.quote(json_data.PROVINCE_CODE)
        local city_id = db.quote(json_data.CITY_CODE)
        local isp_id = db.quote(json_data.ISP_CODE)

        -- 更新或插入
        local sql
        if prop then
            sql = string.format("update ip_pool set country=%s, region=%s, city=%s, isp=%s, country_id=%s, region_id=%s, city_id=%s, isp_id=%s, update_ts=current_timestamp where id=%d returning id",
                    country,
                    region,
                    city,
                    isp,
                    country_id,
                    region_id,
                    city_id,
                    isp_id,
                    prop.id
            )
        else
            sql = string.format("insert into ip_pool(ip, country, region, city, isp, country_id, region_id, city_id, isp_id) values(%s::inet, %s, %s, %s, %s, %s, %s, %s, %s) returning id",
                    quote_ip,
                    country,
                    region,
                    city,
                    isp,
                    country_id,
                    region_id,
                    city_id,
                    isp_id
            )

        end
        local result = db.query(sql)
        if result then
            return {
                id = result[1].id,
                address =  (json_data.country or "") .. (json_data.region or "") .. (json_data.city or "") .. (json_data.isp or "")
            }
        else
            ngx.log(ngx.ERR, "concurrent query ip#", ip)
           -- 并发时可能两个线程同时查询外部服务 导致插入duplicate key
           -- 不会无限递归 最多调用一次 因为出现了duplicate key说明了已经有值了
           return _M.query_ip(ip)
        end

    end
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

function _M.is_ip(ip)
    local chunks = {ip:match("(%d+)%.(%d+)%.(%d+)%.(%d+)")}
    if (#chunks == 4) then
        for _,v in pairs(chunks) do
            if (tonumber(v) < 0 or tonumber(v) > 255) then
                return false
            end
        end
        return true
    else
        return false
    end
end

-- 统计标签数量
-- select  count(1) as topic_count, unnest(topics) unnest_topic from post group by unnest_topic order by topic_count desc
function _M.query_web_stat()
    local start_query = ngx.now()
    local result = db.query([[
        select name from topic order by sort;
        select website, url from link where status=0 order by sort;
        select count(*) from post where post_status=0;
        select count(*) from ip_pool;
        select count(*) from record_page_view;
        select id, title, pv from post where post_status=0 order by pv desc, id desc limit 5;
        select id, title, like_count from post where post_status=0 order by like_count desc, id desc limit 5;
        select id, title, comment_count from post where post_status=0 order by comment_count desc, id desc limit 5;
        select count(1) as count, unnest(topics) as name from post group by name order by count desc;
    ]])

    local memory = ngx.shared.memory
    local success, err = memory:set("web_stat", json.encode(result))

    if not success then
        ngx.log(ngx.ERR, "set shm err#", err)
    --else
    --    local capacity_bytes = memory:capacity()
    --    local free_bytes = memory:free_space()
    --    ngx.log(ngx.ERR, "shm capacity_bytes#" .. capacity_bytes / 1024 / 1024 .. "M; shm free_bytes#" .. free_bytes / 1024 / 1024 .. "M")
    end
    local cost_time = ngx.now() - start_query
    ngx.log(ngx.ERR, "query web_stat cost#" .. cost_time)
    return cost_time
end

return _M
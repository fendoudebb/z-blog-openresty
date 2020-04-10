local db = require "module.db"

local scheme = ngx.var.scheme
local host = ngx.var.host

local base_url = scheme .. "://" .. host

local is_google = ngx.var[1]

local xmlns = [[, 'http://www.baidu.com/schemas/sitemap-mobile/1/' as "xmlns:mobile"]]
local baidu_element = [[xmlelement(name "mobile:mobile", xmlattributes('pc,mobile' as type)),]]

if is_google then
    xmlns = ""
    baidu_element = ""
end

local result = db.query(string.format([[
select
xmlroot(
	xmlelement(name urlset, xmlattributes('http://www.sitemaps.org/schemas/sitemap/0.9' as xmlns %s),
		xmlconcat(
			xmlelement(name url, 
				%s
				xmlelement(name loc, '%s'),
				xmlelement(name lastmod, current_date),
				xmlelement(name changefreq, 'always'),
				xmlelement(name priority, 1)
			),
			xmlagg(
				xmlelement(name url,
					%s
					xmlforest(concat('%s/p/',id,'.html') as loc),
					xmlelement(name lastmod, current_date),
					xmlelement(name changefreq, 'daily'),
					xmlelement(name priority, 0.8)
				)
			order by id desc)
		)
	)
	,version '1.0', standalone yes)::text as sitemap
from post where post_status=0
]], xmlns, baidu_element, base_url, baidu_element, base_url))

ngx.say(result[1].sitemap)
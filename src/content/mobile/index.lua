local json = require "cjson.safe"
local const = require "module.const"
local db = require "module.db"
local req = require "module.req"

local args = ngx.req.get_uri_args()

local sql_args = req.get_page_size(args)

local sql = [[
select id as "postId", title, description, pv, like_count as "likeCount", comment_count as "commentCount", topics, trunc(EXTRACT(EPOCH FROM (create_ts)) * 1000) as "postTime" from post where post_status=0 %s order by id desc limit %d offset %d;
select count(*) as count from post where post_status=0 %s;
]]

local topic = args.topic

local where = ''
if topic and topic ~= '' then
    where = ' and ' .. db.quote(topic) .. '=ANY(topics)'
end

ngx.log(ngx.ERR, "topic#", type(topic))

sql = string.format(sql, where, sql_args.limit, sql_args.offset, where)

ngx.log(ngx.ERR, "sql#", sql)

local result = db.query(sql)

local res = const.ok({ posts = result[1], currentPage = sql_args.page, totalPage = math.ceil(result[2][1].count / sql_args.limit) })

ngx.say(json.encode(res))


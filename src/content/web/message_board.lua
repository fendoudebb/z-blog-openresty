local template = require "resty.template"
local db = require "module.db"
local req = require "module.req"

local sql_args = req.get_page_size(ngx.req.get_uri_args())

--local sql = "select id, nickname, content, floor, to_char(create_ts, 'YYYY-MM-DD') as create_ts, status, browser, os, replies from message_board order by id desc limit %d offset %d"

local sql = [[
with t(id) as (
select id from message_board where root_id is null order by id desc limit %d offset %d
)
select t1.id,t1.nickname,t1.content,t1.floor,to_char(t1.create_ts, 'YYYY-MM-DD') as create_ts,t1.status,t1.os,t1.browser, t2.count, t2.replies from message_board t1 left join
(select root_id, jsonb_agg(jsonb_build_object('id', id, 'status',status,'nickname',nickname,'content',content,'os',os,'browser',browser,'create_ts',to_char(create_ts, 'YYYY-MM-DD'),'reply_id',reply_id,'reply_nickname', reply_nickname) order by id desc) as replies,count(*) from
(select tmp1.id, tmp1.reply_id, tmp1.nickname, tmp1.content, tmp1.status, tmp1.create_ts, tmp1.root_id, tmp1.os, tmp1.browser, tmp2.nickname as reply_nickname from message_board tmp1 left join message_board tmp2 on tmp1.reply_id = tmp2.id where tmp1.root_id in(select id from t)) tmp
group by root_id)
t2 on t1.id = t2.root_id where t1.id in (select id from t) order by id desc
]]

local result = db.query(string.format(sql, sql_args.limit, sql_args.offset))

local memory = ngx.shared.memory
-- TODO 新增留言时记得重新设置
local message_board_count = memory:get("message_board_count")
if not message_board_count then
    message_board_count = db.query("select count(*) as count from message_board where root_id is null")[1].count
    memory:set("message_board_count", message_board_count)
end

template.render("message_board.html", {
    title = "留言板",
    msg = result,
    cur_page = sql_args.page,
    sum_page = math.ceil(message_board_count / sql_args.limit)
})
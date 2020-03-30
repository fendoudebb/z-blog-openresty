local template = require "resty.template"
local db = require "module.db"
local req = require "module.req"

local sql_args = req.get_page_size(ngx.req.get_uri_args())

local sql = "select id, nickname, content, floor, to_char(create_ts, 'YYYY-MM-DD') as create_ts, status, browser, os, replies from message_board order by id desc limit %d offset %d"

local result = db.query(string.format(sql, sql_args.limit, sql_args.offset))

local memory = ngx.shared.memory
-- TODO 新增留言时记得重新设置
local message_board_count = memory:get("message_board_count")
if not message_board_count then
    message_board_count = db.query("select count(*) as count from message_board")[1].count
    memory:set("message_board_count", message_board_count)
end

template.render("message_board.html", {
    title = "留言板",
    msg = result,
    cur_page = sql_args.page,
    sum_page = math.ceil(message_board_count / sql_args.limit)
})
local template = require "resty.template"
local db = require "module.db"
local req = require "module.req"

local sql_args = req.get_page_size(ngx.req.get_uri_args())

local sql = "select word, english_phonetic, american_phonetic, translation, example_sentence, sentence_translation, source, synonyms from english order by create_ts desc limit %d offset %d"

local result = db.query(string.format(sql, sql_args.limit, sql_args.offset))

local memory = ngx.shared.memory
-- TODO 新增留言时记得重新设置
local english_count = memory:get("english_count")
if not english_count then
    english_count = db.query("select count(*) as count from english")[1].count
    memory:set("english_count", english_count)
end


template.render("english.html", {
    title = "英语角",
    keywords = "英语角，IT英语",
    english = result,
    cur_page = sql_args.page,
    sum_page = math.ceil(english_count / sql_args.limit)
})
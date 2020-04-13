local json = require "cjson.safe"
local const = require "module.const"
local db = require "module.db"
local req = require "module.req"

local req_url = ngx.var[1]

local sql
if req_url == "list" then
    local where_cause = ""

    local word = ngx.ctx.body_data.word
    if type(word) == "string" then
        where_cause = "where word=" .. db.val_escape(word)
    end

    local sql_args = req.get_page_size(ngx.ctx.body_data)
    sql = [[
    select count(*) from english %s;
    select id, word, synonyms, english_phonetic, american_phonetic, translation, example_sentence, sentence_translation, source, to_char(create_ts, 'YYYY-MM-DD hh24:MI:ss') from english %s order by id desc limit %d offset %d
    ]]
    sql = string.format(sql, where_cause, where_cause, sql_args.limit, sql_args.offset)
    local result = db.query(sql)
    ngx.say(json.encode(const.ok({
        count = result[1][1].count,
        english = result[2]
    })))
else
    local id = ngx.ctx.body_data.id
    local word = db.val_escape(ngx.ctx.body_data.word)
    local synonyms = db.val_escape(ngx.ctx.body_data.synonyms)
    local english_phonetic = db.val_escape(ngx.ctx.body_data.english_phonetic)
    local american_phonetic = db.val_escape(ngx.ctx.body_data.american_phonetic)
    local translation = db.val_escape(json.encode(ngx.ctx.body_data.translation))
    local example_sentence = db.val_escape(ngx.ctx.body_data.example_sentence)
    local sentence_translation = db.val_escape(ngx.ctx.body_data.sentence_translation)
    local source = db.val_escape(ngx.ctx.body_data.source)
    if type(id) == "number" then
        -- 改
        sql = "update english set word=%s, synonyms=%s, english_phonetic=%s, american_phonetic=%s, translation=%s, example_sentence=%s, sentence_translation=%s, source=%s, update_ts=current_timestamp where id=%d"
        sql = string.format(sql, word, synonyms, english_phonetic, american_phonetic, translation, example_sentence, sentence_translation, source, id)
    else
        -- 增
        local result = db.query("select id from english where word=" .. word)
        if result[1] and result[1].id then
            return ngx.say(json.encode(const.word_repeated()))
        end
        sql = "insert into english(word, synonyms, english_phonetic, american_phonetic, translation, example_sentence, sentence_translation, source) values(%s, %s, %s, %s, %s, %s, %s, %s)"
        sql = string.format(sql, word, synonyms, english_phonetic, american_phonetic, translation, example_sentence, sentence_translation, source)
    end
    db.query(sql)
    ngx.say(json.encode(const.ok()))
end

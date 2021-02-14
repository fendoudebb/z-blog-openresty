local template = require "resty.template"

template.render("topic_list.html", {
    title = '标签列表'
})
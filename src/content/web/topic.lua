local template = require "resty.template"
template.render("topic.html", { message = "Hello, Topic!", topic= ngx.var.topic })
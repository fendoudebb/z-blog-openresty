local template = require "resty.template"

ngx.ctx.topic = ngx.var[1]
template.render("topic.html", { message = "Hello, Topic!", topic= ngx.ctx.topic })
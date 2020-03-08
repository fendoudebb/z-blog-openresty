local template = require "resty.template"

ngx.ctx.search = ngx.var[1]

template.render("search.html", { message = "Hello, Search!", search= ngx.ctx.search })
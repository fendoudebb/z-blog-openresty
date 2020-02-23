local template = require "resty.template"
template.render("search.html", { message = "Hello, Search!", search= ngx.var.search })
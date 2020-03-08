local template = require "resty.template"

ngx.status = ngx.HTTP_NOT_FOUND

template.render("404.html")

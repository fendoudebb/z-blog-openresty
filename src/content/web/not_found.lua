ngx.status = ngx.HTTP_OK

local template = require "resty.template"
template.render("404.html", { message = "Hello, 404!" })

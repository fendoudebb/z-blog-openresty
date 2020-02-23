ngx.status = ngx.HTTP_OK

local template = require "resty.template"
template.render("index.html", { message = "Hello, 404!" })

ngx.status = ngx.HTTP_OK

local template = require "resty.template"
template.render("index.html", { message = "Hello, 404!" })

-- ngx.timer.at 代替 ngx.eof()
ngx.eof()
ngx.sleep(3)
ngx.log(ngx.ERR, " url=", ngx.var.request_uri)


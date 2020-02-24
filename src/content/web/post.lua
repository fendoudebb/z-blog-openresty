local template = require "resty.template"
template.render("post.html", { message = "Hello, Post!", postId= ngx.var.post_id })

-- ngx.timer.at 代替 ngx.eof()
ngx.eof()
ngx.sleep(3)
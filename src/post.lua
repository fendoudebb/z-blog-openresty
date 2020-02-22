local template = require "resty.template"
template.render("post.html", { message = "Hello, Post!", postId= ngx.var.post_id })

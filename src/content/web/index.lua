local template = require "resty.template"

template.render("index.html", { message = "Hello, Index!" })
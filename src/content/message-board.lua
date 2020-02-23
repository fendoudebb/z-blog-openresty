local template = require "resty.template"
template.render("message-board.html", { message = "Hello, message-board!"})
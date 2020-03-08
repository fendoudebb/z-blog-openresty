local template = require "resty.template"

template.render("message_board.html", { message = "Hello, message_board!"})
local template = require "resty.template"

local tool = ngx.var[1]
template.render("tool_" .. tool .. ".html")

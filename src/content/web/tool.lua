local template = require "resty.template"

local tool = ngx.var[1]
if tool == "json" then
    template.render("tool_json.html", {
        title = "JSON格式化工具",
        keywords = "格式化json,解析json,压缩json,格式化,解析,压缩",
        description = "格式化json,解析json,压缩json,格式化,解析,压缩"
    })
elseif tool == "timestamp" then
    template.render("tool_timestamp.html", {
        title = "时间戳转换",
        keywords = "时间戳转换，转换时间戳，格式化时间戳，时间戳格式化，时间戳",
        description = "时间戳转换，timestamp"
    })
elseif tool == "ip" then
    template.render("tool_ip.html", {
        title = "IP查询",
        keywords = "IP查询，查询IP，IP归属地",
        description = "IP查询，查询IP，IP归属地"
    })
else
    ngx.status = ngx.HTTP_NOT_FOUND
    template.render("404.html")
end


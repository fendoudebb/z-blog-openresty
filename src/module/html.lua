local _M = { _VERSION = "0.01" }

function _M.clear_html(html)
    html = string.gsub(html, '<script[%a%A]->[%a%A]-</script>', '')
    html = string.gsub(html, '<style[%a%A]->[%a%A]-</style>', '')
    html = string.gsub(html, '<[%a%A]->', '')
    --删除空行
    html = string.gsub(html, '\n\r', '\n')
    html = string.gsub(html, '%s+\n', '\n')
    html = string.gsub(html, '\n+', '\n')
    html = string.gsub(html, '\n%s+', '\n')
    --删除前后空格
    html = string.gsub(html, '^%s+', '')
    html = string.gsub(html, '%s+$', '')

    return html
end

function _M.strip_tags(html)
    local str = ngx.re.gsub(html, "</?[^>]+>", "")
    if str then
        html = str
    else
        html = string.gsub(html, "<[%a%A]->", "")
    end
    return html
end

return _M
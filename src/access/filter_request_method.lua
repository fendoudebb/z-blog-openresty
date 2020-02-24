local _M = {}

function _M.filter_non_get()
    if 'GET' ~= ngx.req.get_method() then
        ngx.log(ngx.ERR, "request_method=", ngx.req.get_method(), ", non match=GET")
        ngx.exit(ngx.HTTP_NOT_FOUND)
    end
end

function _M.filter_non_post()
    if 'POST' ~= ngx.req.get_method() then
        ngx.log(ngx.ERR, "request_method=", ngx.req.get_method(), ", non match=POST")
        ngx.exit(ngx.HTTP_NOT_FOUND)
    end
end


return _M
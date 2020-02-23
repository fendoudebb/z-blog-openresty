if ngx.req.get_method() ~= 'GET' then
    ngx.log(ngx.ERR, "get_method=", ngx.req.get_method(), ", get=", ngx.HTTP_GET)
    ngx.exit(ngx.HTTP_NOT_FOUND)
end
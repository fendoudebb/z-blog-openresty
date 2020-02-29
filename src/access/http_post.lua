util.filter_non_post_method()

ngx.ctx.ua = util.parse_ua()

ngx.req.read_body()
ngx.ctx.data = ngx.req.get_body_data()
if not ngx.ctx.data then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end
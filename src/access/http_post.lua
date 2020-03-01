local headers = ngx.req.get_headers()
ngx.ctx.client_ip = headers["X-REAL-IP"] or headers["X_FORWARDED_FOR"] or ngx.var.remote_addr or "0.0.0.0"

util.filter_non_post_method(ngx.var.request_method)

ngx.ctx.ua = util.parse_ua(ngx.var.http_user_agent)

ngx.req.read_body()
ngx.ctx.data = ngx.req.get_body_data()
if not ngx.ctx.data then
    ngx.exit(ngx.HTTP_BAD_REQUEST)
end
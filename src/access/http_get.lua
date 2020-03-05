local headers = ngx.req.get_headers()
ngx.ctx.client_ip = headers["X-REAL-IP"] or headers["X_FORWARDED_FOR"] or ngx.var.remote_addr or "0.0.0.0"

req.filter_non_get_method(ngx.var.request_method)

ngx.ctx.ua = req.parse_ua(ngx.var.http_user_agent)
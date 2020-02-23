local request_time = ngx.now() - ngx.req.start_time()
ngx.log(ngx.ERR, "url=", ngx.var.request_uri, ", cost_time=", string.format("%.2f", request_time), ", http_version=", ngx.req.http_version())
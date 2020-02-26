local frm = require('access.filter_request_method')
frm.filter_non_get()
ngx.ctx.topic = ngx.var[1]
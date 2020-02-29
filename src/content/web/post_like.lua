if ngx.ctx.data then
    local obj = json.decode(ngx.ctx.data)
    ngx.say('{"code":200}')
    ngx.log(ngx.ERR, obj.test_filed)
end
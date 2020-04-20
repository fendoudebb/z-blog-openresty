# z-blog-openresty

## 依赖
- [OpenResty](https://github.com/openresty/openresty)：基于`Nginx`的高性能`Web`服务器
- [lua-resty-template](https://github.com/bungle/lua-resty-template)：适用`Nginx`和`OpenResty`的`HTML`模板渲染引擎
- [pgmoon](https://github.com/leafo/pgmoon)：`PostgreSQL`的`Lua`驱动
- [lua-resty-woothee](https://github.com/woothee/lua-resty-woothee)：基于`Woothee`的`User-Agent`解析器
- [lua-resty-http](https://github.com/ledgetech/lua-resty-http)：`OpenResty`和`ngx_lua`中的`HTTP`客户端

## 安装依赖
```bash
luarocks install lua-resty-template
luarocks install pgmoon
luarocks install lua-resty-woothee
luarocks install lua-resty-http
```

luarocks安装可参考  
[OpenResty整合luarocks-Windows10](https://www.zhangbj.com/p/523.html)

## 初始化数据库
```sql
initdb
psql -d postgres -f pg_schema.sql
```
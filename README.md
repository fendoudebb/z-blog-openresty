# z-blog-openresty

## 依赖

- [OpenResty](https://github.com/openresty/openresty)：基于`Nginx`的高性能`Web`服务器
- [lua-resty-template](https://github.com/bungle/lua-resty-template)：适用`Nginx`和`OpenResty`的`HTML`模板渲染引擎
- [pgmoon](https://github.com/leafo/pgmoon)：`PostgreSQL`的`Lua`驱动
- [lua-resty-woothee](https://github.com/woothee/lua-resty-woothee)：基于`Woothee`的`User-Agent`解析器
- [lua-resty-http](https://github.com/ledgetech/lua-resty-http)：`OpenResty`和`ngx_lua`中的`HTTP`客户端
- [lua-resty-auto-ssl](https://github.com/auto-ssl/lua-resty-auto-ssl)：自动注册和更新`Let's Encrypt`的`https`证书（需编写`Lua`代码）
- [certbot](https://certbot.eff.org)：自动注册和更新`Let's Encrypt`的`https`证书（安装成`Linux`服务后自动更新证书，无需编写代码）

## 安装依赖

```shell
luarocks install lua-resty-template 2.0-1
luarocks install pgmoon 1.12.0-1
luarocks install lua-resty-woothee 1.12.0-1
luarocks install lua-resty-http 0.15-0
luarocks install lua-resty-auto-ssl 0.13.1-1
```

`LuaRocks`安装可参考  

- [OpenResty 整合 LuaRocks - Windows10](https://www.zhangbj.com/p/523.html)
- [OpenResty 整合 LuaRocks - Linux](https://www.zhangbj.com/p/810.html)

## 初始化数据库

```shell
initdb
psql -d postgres -f pg_schema.sql
```

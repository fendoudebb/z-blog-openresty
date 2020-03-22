后端请求均使用POST请求方法，Content-Type=application/json，除登录接口外其余接口均携带token头信息。

公共返回字段：`code`, `msg`

### 登录
/login

*请求参数*

参数名|类型|必需|描述
-|-|-|-
username|string|是|用户名
password|string|是|密码

*返回值*

参数名|类型|必需|描述
-|-|-|-
token|string|是|登录标识
roles|array|是|角色名

*返回示例*
```json
{
    "code": 0,
    "msg": "请求成功",
    "data": {
        "token": "c8ce0ace8cd7f94e5b8a22486ec76e8c",
        "roles": [
            "ROLE_ADMIN"
        ]
    }
}
```

### 退出
*返回示例*
```json
{
    "code": 0,
    "msg": "请求成功"
}
```

### 文章上下线
/post/audit

*请求参数*

参数名|类型|必需|描述
-|-|-|-
id|number|是|文章id
status|number|是|0：上线，1：下线 

*返回示例*
```json
{
    "code": 0,
    "msg": "请求成功"
}
```
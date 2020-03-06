local _M = {
    ok = {
      code = 0,
      msg = "请求成功"
    },
    post_not_exist = {
        code = 1000,
        msg = "文章不存在"
    },
    post_like_already = {
        code = 1001,
        msg = "已点过赞啦~"
    }
}

return _M
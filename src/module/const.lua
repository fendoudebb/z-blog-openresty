local _M = { _VERSION = "0.01" }

function _M.ok(data)
    return {
        code = 0,
        msg = "请求成功",
        data = data
    }
end

function _M.fail(msg)
    return {
        code = -1,
        msg = msg or "请求失败",
    }
end

function _M.post_not_exist()
    return {
        code = 1000,
        msg = "文章不存在"
    }
end

function _M.post_like_already()
    return {
        code = 1001,
        msg = "已点过赞啦"
    }
end

function _M.post_comment_close()
    return {
        code = 1002,
        msg = "评论已关闭"
    }
end

function _M.query_ip_fail()
    return {
        code = 1003,
        msg = "查询失败，请稍后再试"
    }
end

function _M.login_fail()
    return {
        code = 2000,
        msg = "用户名或密码不正确"
    }
end

return _M
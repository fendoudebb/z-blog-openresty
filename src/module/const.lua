local _M = { _VERSION = "0.01" }

function _M.ok(data)
    return {
        code = 0,
        msg = "请求成功",
        data = data
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
        msg = "已点过赞啦~"
    }
end

return _M
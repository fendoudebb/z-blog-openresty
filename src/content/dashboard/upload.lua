local json = require "cjson.safe"
local const = require "module.const"
local upload = require "resty.upload"

--local root_path = "z_blog_openresty/resources/img/" .. ngx.re.gsub(ngx.today(), "-", "") .. "/"
local root_path = "z_blog_openresty/resources/uploads/img/"

local chunk_size = 4096
local form = upload:new(chunk_size)

local file

local file_name

while true do
    local typ, res, err = form:read()

    if not typ then
        ngx.log(ngx.ERR, "upload img failed to read#" .. err)
        ngx.say(json.encode(const.fail("failed to read#" .. err)))
        return
    end

    if typ == "header" then
        -- res
        -- ["Content-Disposition","form-data; name=\"image\"; filename=\"aa.aa.png\"","Content-Disposition: form-data; name=\"image\"; filename=\"aa.png\""]

        -- 限制 image 字段
        local m_form_data = ngx.re.match(res[2], [[form-data; name="(.+)";]])
        -- {"0":"form-data; name=\"image\";","1":"image"}
        ngx.log(ngx.ERR, json.encode(res[2]))
        ngx.log(ngx.ERR, json.encode(m_form_data))

        if m_form_data then
            local form_data = m_form_data[1]
            if form_data ~= "image" then
                ngx.log(ngx.ERR, "upload img invalid param#" .. form_data)
                ngx.say(json.encode(const.fail("invalid param#" .. form_data)))
                return
            end
        end

        local m_file_name = ngx.re.match(res[2], [[filename="(.+)\.(.+)"]])
        --  {"0":"filename=\"aa.aa.png\"","1":"aa.aa","2":"png"}

        if m_file_name then
            file_name = ngx.md5(ngx.now() .. m_file_name[1]) .. "." .. m_file_name[2]
            file = io.open(root_path .. file_name, "w+b")
            if not file then
                ngx.log(ngx.ERR, "upload img failed to open file#" .. root_path .. file_name)
                ngx.say(json.encode(const.fail("failed to open file#" .. file_name)))
                return
            end
        end
    elseif typ == "body" then
        if file then
            file:write(res)
        end
    elseif typ == "part_end" then
        if file then
            file:close()
            file = nil
        end
    elseif typ == "eof" then
        break
    else
        -- do nothing
    end
end

if not file_name then
    ngx.log(ngx.ERR, "upload img no file#" .. ngx.var.http_user_agent)
    ngx.say(json.encode(const.fail("missing param")))
    return
end

local file_url = "https://www.zhangbj.com/uploads/img/" .. file_name

ngx.say(json.encode(const.ok(file_url)))

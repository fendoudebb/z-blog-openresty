local json = require "cjson.safe"
local const = require "module.const"
local upload = require "resty.upload"

--local root_path = "z_blog_openresty/resources/img/" .. ngx.re.gsub(ngx.today(), "-", "") .. "/"
local relative_path = "uploads/img/"
local root_path = "z_blog_openresty/resources/" .. relative_path

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
        local param_info = ngx.re.match(res[2], [[form-data; name="(.+)";]])
        -- {"0":"form-data; name=\"image\";","1":"image"}

        if param_info then
            local param = param_info[1]
            if param ~= "image" then
                ngx.log(ngx.ERR, "upload img invalid param#" .. param)
                ngx.say(json.encode(const.fail("invalid param#" .. param)))
                return
            end

            local file_info = ngx.re.match(res[2], [[filename="(.+)\.(.+)"]])
            --  {"0":"filename=\"aa.aa.png\"","1":"aa.aa","2":"png"}

            if file_info then
                local file_extension = file_info[2]
                local typ_match = ngx.re.match(file_extension, [[(png)|(jpeg)|(jpg)|(gif)|(svg)|(bmp)|(webp)]], "i")

                if not typ_match then
                    ngx.log(ngx.ERR, "upload img file type error#" .. file_extension)
                    ngx.say(json.encode(const.fail("file type error#" .. file_extension)))
                    return
                end

                file_name = ngx.md5(ngx.now() .. ngx.var.pid .. file_info[1]) .. "." .. file_extension:lower()
                file = io.open(root_path .. file_name, "w+b")
                if not file then
                    ngx.log(ngx.ERR, "upload img failed to open file#" .. root_path .. file_name)
                    ngx.say(json.encode(const.fail("failed to open file#" .. file_name)))
                    return
                end
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
    ngx.log(ngx.ERR, "upload img invalid file#" .. ngx.var.http_user_agent)
    ngx.say(json.encode(const.fail("invalid file")))
    return
end

local file_url = string.format("/%s%s", relative_path, file_name)

ngx.say(json.encode(const.ok(file_url)))

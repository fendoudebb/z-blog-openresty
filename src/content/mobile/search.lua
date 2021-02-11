local json = require "cjson.safe"
local const = require "module.const"
local http = require "resty.http"
local req = require "module.req"

local search = ngx.var[1]

local pagination_args = req.get_page_size(ngx.req.get_uri_args())

local param = {
    _source = {
        excludes = {
            "title",
            "content"
        }
    },
    from = pagination_args.offset,
    size = pagination_args.limit,
    min_score = 0.1,
    query = {
        bool = {
            must = {
                {
                    match = {
                        offline = false
                    }
                }
            },
            should = {
                {
                    multi_match = {
                        query = search,
                        fuzziness = "AUTO", -- 模糊查询，自动修正（可以设置成0,1,2等）
                        fields = {
                            "title",
                            "content"
                        }
                    }
                }
            },
            minimum_should_match = "50%"
        }
    },
    highlight = {
        order = "score",
        pre_tags = {
            "<em>"
        },
        post_tags = {
            "</em>"
        },
        no_match_size = 150,
        number_of_fragments = 1,
        fragment_size = 100,
        require_field_match = false,
        fields = {
            title = {},
            content = {}
        }
    }
}

local httpc = http.new()
local res, err = httpc:request_uri("http://127.0.0.1:9200/post/_search?filter_path=-_shards,-timed_out,-hits.total.relation", {
    method = "GET",
    body = json.encode(param),
    headers = {
        ["Content-Type"] = "application/json",
    },
    keepalive_timeout = 5000 -- 毫秒
})

if res then
    local data = json.decode(res.body)
    --hits.total = data.hits.total.value
    --hits.hits = data.hits.hits
    ngx.ctx.search_stat = {
        search = search,
        took = data.took,
        hits = data.hits.total.value
    }

    local hits = {}

    for _, p in ipairs(data.hits.hits) do
        local post = {
            postId = p._source.postId,
            postTime = p._source.postTime,
            topics = p._source.topics,
            title = p.highlight.title[1],
            content = p.highlight.content[1],
        }
        table.insert(hits, post)
    end

    local response = const.ok({
        hits = hits,
        currentPage = pagination_args.page,
        totalPage = math.ceil(data.hits.total.value / pagination_args.limit)
    })

    ngx.say(json.encode(response))
else
    ngx.log(ngx.ERR, "es search err#", err)
    return req.request_error(ngx.HTTP_NOT_FOUND, const.post_not_exist())
end



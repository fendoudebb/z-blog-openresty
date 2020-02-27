require('resty.core')
pgmoon = require('pgmoon')
template = require('resty.template')
template.caching(false); -- 生产环境删除这条
json = require('cjson')
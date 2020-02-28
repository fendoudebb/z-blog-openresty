require('resty.core')
json = require('cjson')
pgmoon = require('pgmoon')
template = require('resty.template')
template.caching(false); -- 生产环境删除这条
woothee = require('resty.woothee')
config = require('init/config')
util = require('init/util')
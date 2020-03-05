require('resty.core')
json = require('cjson.safe')
pgmoon = require('pgmoon')
template = require('resty.template')
template.caching(false); -- 生产环境删除这条
woothee = require('resty.woothee')
http = require('resty.http')

-- custom
const = require('init/const')
config = require('init/config')
req = require('init/req')
util = require('init/util')
db = require('init/db')
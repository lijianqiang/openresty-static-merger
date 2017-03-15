--加载配置文件
config = require "config.config"

local nlog		= ngx.log
local str_byte  = string.byte
local B_SLASH   = str_byte("/")

local function init()
    -- check cache path
	local cache_path = config.path.cache
	local static_path = config.path.static
	
	local cache_len = #cache_path
	if B_SLASH == str_byte(cache_path, cache_len, cache_len) then
		cache_path = str_sub(cache_path, 1, cache_len -1)
		config.path.cache = cache_path
	end
	
	nlog(ngx.INFO, "[app]init cache path:", cache_path, "[/app]")
	
	local static_len = #static_path
	if B_SLASH == str_byte(static_path, static_len, static_len) then
		static_path = str_sub(static_path, 1, static_len -1)
		config.path.static = static_path
	end
	
	nlog(ngx.INFO, "[app]init static path:", static_path, "[/app]")
	
    local fp = io.open(cache_path, "r")
    if fp == nil then
        os.execute('mkdir -p ' .. cache_path)
        nlog(ngx.WARN, "[app]mkdir cache path:", cache_path, "[/app]")
    else
	    fp:close()
    end
	nlog(ngx.INFO, "[app] *** init finished **** [/app]")
end

init()


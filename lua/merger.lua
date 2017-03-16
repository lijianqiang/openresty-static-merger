--
-- 静态文件(js, css)合并输出
-- lijianqiang
--


-- 本地化变量
local DEBUG     = ngx.DEBUG
local INFO      = ngx.INFO
local NOTICE    = ngx.NOTICE
local WARN      = ngx.WARN
local ERR       = ngx.ERR

-- 本地化方法
local nlog      = ngx.log
local io_open	= io.open
local str_sub   = string.sub
local str_gsub	= string.gsub
local ngx_find  = ngx.re.find
local ngx_md5 	= ngx.md5

-- 本地私有变量
local RELEASE_VERSION = config.release_version
local CACHE_MODE = config.cache_mode
local CACHE_PATH = config.path.cache
local STATIC_PATH = config.path.static
local URI_SPL = config.uri_spl

local SHARED_CACHE = ngx.shared.static_cache
--local CACHE_ITEM_SIZE = ngx.cache_item_size


-- 本地私有方法
local build_output
local get_content_cache
local set_content_cache
local build_cache_key
local build_static_content
local get_file_cache
local set_file_cache
local get_shared_cache
local set_shared_cache
local get_file_name
local split
local is_table_empty

local lrucache = require "resty.lrucache"
local LC = lrucache.new(200) -- allow up to CACHE_ITEM_SIZE items in the cache
if not LC then
	return error("failed to create the lrucache: " .. (err or "unknown"))
end

local _M = {_VERSION = "20170315"}
local mt = { __index = _M }

-- table.new(narr, nrec)
local ok, new_tab = pcall(require, "table.new")
if not ok then
    new_tab = function () return {} end
end



function _M.run()
    local request_uri = ngx.var.request_uri
    
	local ok, content = pcall(build_output, request_uri)
	if not ok then
	    nlog(ERR, "[app][***runtime***] error:", content, "[/app]")
	    ngx.exit(401)
		return
	elseif not content or content == "" then
	    nlog(ERR, "[app][***reponse***] output is nil, request_uri:", request_uri, "[/app]")
	    ngx.exit(404)
		return
	else
	    ngx.say(content)
	end
end

--
-- 构建输出，构建缓存
--
build_output = function(request_uri)

    nlog(INFO, "[app]request_uri:", request_uri, "[/app]")
	
	local key = build_cache_key(request_uri)
	if not key or key == "" then
	    nlog(ERR, "[app]cache key is nil[/app]")
		return nil
	end
	
	local cache = get_content_cache(key)
	if cache ~= nil then
	    nlog(DEBUG, "[app]cache hit[/app]")
		return cache
	end
	
    local content = build_static_content(request_uri)
	if content ~= nil and content ~= "" then
	    nlog(DEBUG, "[app]cache setting[/app]")
	    set_content_cache(key, content)
	end
	
	return content
end

--
-- 构建缓存key
--
build_cache_key = function(request_uri)
	local uri_md5 = LC:get(request_uri)
	if not uri_md5 then
	    nlog(DEBUG, "[app]key setting[/app]")
		uri_md5 = ngx_md5(request_uri)
		LC:set(request_uri, uri_md5)
	end
	if CACHE_MODE == 2 then
	    uri_md5 = CACHE_PATH .. "/" .. uri_md5
	end
	
	return uri_md5
end

--
-- 获取缓存内容
--
get_content_cache = function(key)
    local data = LC:get(key)
	if data ~= nil and data ~= "" then
	    nlog(DEBUG, "[app]lurcache hit[/app]")
		return data
	end
	
	if CACHE_MODE == 2 then
		return get_file_cache(key)
	end
	
	return get_shared_cache(key)
end

--
-- 设置缓存内容
--
set_content_cache = function(key, value)
    LC:set(key, value)
	if CACHE_MODE == 2 then
		return set_file_cache(key, value)
	end
	
	return set_shared_cache(key, value)
end

--
-- 使用nginx的shared缓存
--
get_shared_cache = function(key)	
	return SHARED_CACHE:get(key)
end

--
-- 使用nginx的shared缓存
--
set_shared_cache = function(key, cache)
    SHARED_CACHE:set(key, cache)
end

--
-- 使用文件缓存
--
get_file_cache = function(cache_file)
    local content = nil
	local cf_read, err = io_open(cache_file, "r")
	if cf_read ~= nil then
        content = cf_read:read("*all")
        cf_read:close()
    else
        nlog(WARN, "[app]file cache is nil[/app]")
    end
	return content
end

--
-- 使用文件缓存
--
set_file_cache = function(cache_file, cache)
    -- save cache file
    local cf_write, err = io_open(cache_file, "w")
   	if cf_write ~= nil then
        cf_write:write(cache)
        cf_write:close()
    else
        nlog(ERR, "[app]file cache write err:", err, "[/app]")
    end
end

--
-- 读取原始文件，构建内容
--
build_static_content = function(request_uri)
    local uri_tbl = split(request_uri, URI_SPL)
	if is_table_empty(uri_tbl) then
	    nlog(ERR, "[app]request_uri to table error, request_uri:", request_uri, "[/app]")
		return nil
	end
	
	local data = ""
	
    -- read table and get static data
	local fp_read, err
	local file_name = nil
    for key, value in ipairs(uri_tbl) do
	    file_name = get_file_name(value)
        fp_read, err = io_open(file_name, "r")
        if fp_read ~= nil then
            data = data .. fp_read:read("*all")
            fp_read:close()
        else
            nlog(ERR, "[app]content file read error, file:", file_name, ", err:", err, "[/app]")
        end
    end
    
	return data
end

--
-- 拼接绝对地址的文件名
--
get_file_name = function(request_name)
    local from, to, err = ngx_find(request_name, '=')
	--nlog(DEBUG, "[app]get_file_name:file:", request_name, ", from:", from, ", to:", to, ", err:", err, "[/app]")
	if from then
		return STATIC_PATH .. str_sub(request_name, 1, from - 3)
	end
    return STATIC_PATH .. request_name
end


split = function(str, spl)
    if str == nil or spl == nil then return nil end
    local rt = {}
    str_gsub(str, '[^'..spl..']+', function(w) table.insert(rt, w) end )
    return rt
end

is_table_empty = function(t)
    if t == nil or next(t) == nil then
        return true
    end
    if type(t) ~= "table" then
        return true
    end

    return false
end


return _M
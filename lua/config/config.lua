local config = {
    path = {
	    cache = "/data/wwwroot/openresty-static-merger/cache", 			-- cache文件保存路径
	    static = "/data/wwwroot/openresty-static-merger/demo/common"	-- 原始static文件存放路径
	},
	
	cache_mode = 1,					-- 缓存方式，1：ngx.shared， 2：本地file
	uri_spl = ";",					-- uri里的拼接符号
	release_version = "20170315"  	-- 当前static文件发布的版本号
}

return config

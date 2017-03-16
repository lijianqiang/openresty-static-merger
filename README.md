# openresty-static-merger
web静态资源合并输出，主要用于合并静态文件，减少http请求，加快静态文件访问速度

通常用于js、css类文本型静态文件


### 效果

##### 合并前

合并前代码块

	<link type="text/css" href="/static/style/body.css" rel="stylesheet" media="screen"/>  
	<link type="text/css" href="/static/style/content.css" rel="stylesheet" media="screen"/>  
	<script type="text/javascript" src="/static/js/jquery-1.12.2.min.js"></script>  
	<script type="text/javascript" src="/static/js/bootstrap.min.js"></script>  
	
合并前加载过程

![合并前加载过程](https://github.com/lijianqiang/openresty-static-merger/blob/master/img/origin_1.jpg "origin request process")


##### 合并后

合并后代码块

	<link type="text/css" href="/static/style/body.css?v=20170315;/static/style/content.css?v=20170315" rel="stylesheet" media="screen"/>
    <script type="text/javascript" src="/static/js/jquery-1.12.2.min.js?v=20170315;/static/js/bootstrap.min.js?v=20170315"></script>

	
合并后加载过程，首次

> 首次加载，需要构建缓存

![合并后加载过程1](https://github.com/lijianqiang/openresty-static-merger/blob/master/img/merger_1.jpg "merge request process")

合并后加载过程，再次

> 再次加载，缓存已建立

![合并后加载过程2](https://github.com/lijianqiang/openresty-static-merger/blob/master/img/merger_2.jpg "merge request process")


### 使用

基于openresty

假定openresty安装路径
> /data/program/openresty

	|--/data/program/openresty
	|                        |--nginx
	|                               |--conf
	|                                      |--nginx.conf

demo部署路径

	|--/data/wwwroot/xxxxx
	|                     |--demo
	|                            |--common
	|                            |--origin
	|                            |--merge
	|                     |--lua
	|                     |--cache


### 配置

lua配置文件
> lua/config/config.lua

	local config = {
		path = {
			cache = "/data/wwwroot/xxxxx/cache",          -- cache文件保存路径
			static = "/data/wwwroot/xxxxx/demo/common"    -- 原始static文件存放路径
		},
	
		cache_mode = 1,					-- 缓存方式，1：ngx.shared， 2：本地file
		uri_spl = ";",					-- uri里的拼接符号
		release_version = "20170315"    -- 当前static文件发布的版本号
	}



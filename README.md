# openresty-static-merger
web静态资源合并输出，主要用于合并静态文件，减少http请求，加快静态文件访问速度的模块。

目前只支持js、css类文本型静态文件


### 效果

#####合并前

合并前代码块

	<link type="text/css" href="/static/style/body.css" rel="stylesheet" media="screen"/>  
	<link type="text/css" href="/static/style/content.css" rel="stylesheet" media="screen"/>  
	<script type="text/javascript" src="/static/js/jquery-1.12.2.min.js"></script>  
	<script type="text/javascript" src="/static/js/bootstrap.min.js"></script>  
	
合并前加载过程

![合并前加载过程](https://github.com/lijianqiang/openresty-static-merger/blob/master/jpg/origin_1.jpg "origin request process")


#####合并后

合并后代码块

	<link rel="shortcut icon" href="/static/icons/android.png">  
    <link type="text/css" href="/static/style/body.css?v=20170315;/static/style/content.css?v=20170315" rel="stylesheet" media="screen"/>

	
合并后加载过程，首次

![合并前加载过程](https://github.com/lijianqiang/openresty-static-merger/blob/master/jpg/merger_1.jpg "origin request process")

合并后加载过程，缓存

![合并前加载过程](https://github.com/lijianqiang/openresty-static-merger/blob/master/jpg/merger_2.jpg "origin request process")


### 使用

基于openresty

假定openresty安装路径
> /data/program/openresty

	|--/data/program/openresty
	|						`--nginx
	|								`--conf
	|									   `--nginx.conf

demo部署路径

	|--/data/wwwroot/xxxxx
	|					`--demo
	|							`--common
	|							`--origin
	|							`--merge
	|					`--lua
	|					`--cache






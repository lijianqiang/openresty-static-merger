local config = {
    path = {
	    cache = "/data/wwwroot/openresty-static-merger/cache", 			-- cache�ļ�����·��
	    static = "/data/wwwroot/openresty-static-merger/demo/common"	-- ԭʼstatic�ļ����·��
	},
	
	cache_mode = 1,					-- ���淽ʽ��1��ngx.shared�� 2������file
	uri_spl = ";",					-- uri���ƴ�ӷ���
	release_version = "20170315"  	-- ��ǰstatic�ļ������İ汾��
}

return config

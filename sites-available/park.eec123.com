## Basic reverse proxy server ##
## define my wireguardclient backend for mhostms.eec123.com ##
upstream park  {
    ##server park.zhltraffic.com:80; #
    server speedtest.cn;
}
 
## Start www.quancha.cn ##
server {
    listen 7281;
    server_name park.eec123.com;
 
    access_log  /var/log/nginx/park.eec123.com/access.log  main;
    error_log  /var/log/nginx/park.eec123.com/error.log;
    root   html;
    index  index.html index.htm index.php;
 
    ## send request back to apache ##
    location / {
        proxy_pass  http://park; #bind to upstream apachephp
 
        #Proxy Settings
        proxy_redirect     false;
        proxy_set_header   Host             $host;
        proxy_set_header   X-Real-IP        $remote_addr;
        proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_max_temp_file_size 0;
        proxy_connect_timeout      90;
        proxy_send_timeout         90;
        proxy_read_timeout         90;
        proxy_buffer_size          10240k;
        proxy_buffers              4 10240k;
        proxy_busy_buffers_size    10240k;
        proxy_temp_file_write_size 10240k;
	client_max_body_size       10240k;
   }
}


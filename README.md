# php 7.3-fpm

## 使用方法
`podman run -d --name css.keruix.com -v /var/www/html:/data/www/css.keruix.com --ip 10.88.1.1 taoxin/php`

## 配合Nginx或Caddy,以Caddy为例
#### 启动Caddy
`podman run -d --name caddy -p 80:80 -p 443:443 -v /data/caddy/Caddyfile:/etc/caddy/Caddyfile -v /data/www:/srv/www --ip 10.88.88.88 caddy`

#### 配置Caddyfile
```
css.keruix.com {
    root * /srv/www/css.keruix.com/public
    php_fastcgi 10.88.1.1:9000 {
        root /var/www/html/public/
    }
    file_server
    @index path_regexp index /(index|admin).php/(.*)$
    rewrite @index /{re.index.1}.php?{query}&s={re.index.2}
    try_files {path} /index.php?{query}&s={path}
}
```

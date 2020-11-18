#!/bin/bash

echo "${TIME_ZONE}" > /etc/timezone
ln -sf /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime

chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

exec "$@"

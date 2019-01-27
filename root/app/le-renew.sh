#!/usr/bin/with-contenv bash

. /config/donoteditthisfile.conf

echo "<------------------------------------------------->"
echo
echo "<------------------------------------------------->"
echo "cronjob running on "$(date)
echo "Running certbot renew"
if [ "$ORIGVALIDATION" = "dns" ] || [ "$ORIGVALIDATION" = "duckdns" ]; then
  certbot -n renew \
    --post-hook "if ps aux | grep [n]ginx: > /dev/null; then s6-svc -h /var/run/s6/services/nginx; fi; \
    tar -czf /config/etc/letsencrypt/letsencrypt-config.tar.gz -C / etc/letsencrypt/"
else
  certbot -n renew \
    --pre-hook "if ps aux | grep [n]ginx: > /dev/null; then s6-svc -d /var/run/s6/services/nginx; fi" \
    --post-hook "if ps aux | grep 's6-supervise nginx' | grep -v grep > /dev/null; then s6-svc -u /var/run/s6/services/nginx; fi; \
    tar -czf /config/etc/letsencrypt/letsencrypt-config.tar.gz -C / etc/letsencrypt/"
fi

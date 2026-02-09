# 使用Stun服务实现内网穿透与动态域名绑定

## 光猫路由模式

## 对入户光猫解锁telnet并开启DMZ与端口转发服务

## OpenWRT配置`NATMap`插件的stun打洞服务

## CloudFlareDDNS脚本绑定域名

```bash
#!/bin/sh
DOMAIN='router.frankiemc.top'
ZONEID='8abaf934e89e9ab909e193183c1c60d2'
PAGEID='2e19b77edfd77843c3e8b5f13e756ee0'
APIKEY='LNjBftC6ZTDgIJWJE8p6WoGN9Q-KYSjI_RJYXZ87'
TARGET="http://${1}:${2}"

while true; do
    curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/${ZONEID}/pagerules/${PAGEID}" \
      -H "Authorization: Bearer ${APIKEY}" \
      -H "Content-Type: application/json" \
      --data "{
        \"status\":\"active\",
        \"targets\":[{\"target\":\"url\",\"constraint\":{\"operator\":\"matches\",\"value\":\"$DOMAIN\"}}],
        \"actions\":[{\"id\":\"forwarding_url\",\"value\":{\"url\":\"$TARGET\",\"status_code\":302}}]
      }"
    if [ $? -eq 0 ]; then
      break
    fi
done
```

#!/bin/sh

# dnspod dns & ali dns server 
TARGETS="v6ns1.dnspod.net 2400:3200:baba::1"
FAIL_COUNT_FILE="/tmp/ipv6_failcount"
MAX_FAIL=3
WAN6="WAN6"

fail_ping=0

for host in $TARGETS; do
  ping6 -c 2 -W 2 $host > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    fail_ping=$((fail_ping + 1))
  fi
done

# 如果两个都失败
if [ "$fail_ping" -ge 2 ]; then
  count=$(cat $FAIL_COUNT_FILE 2>/dev/null || echo 0)
  count=$((count + 1))
  echo $count > $FAIL_COUNT_FILE

  logger -t ipv6-check "IPv6 check failed ($count/$MAX_FAIL)"

  if [ "$count" -ge "$MAX_FAIL" ]; then
    logger -t ipv6-check "IPv6 unreachable for $MAX_FAIL times, restarting wan6..."
    ifdown $WAN6 && sleep 2 && ifup $WAN6
    echo 0 > $FAIL_COUNT_FILE  # 重置失败计数
  fi
else
  logger -t ipv6-check "IPv6 is OK, resetting fail count."
  echo 0 > $FAIL_COUNT_FILE
fi
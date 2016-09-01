#!/usr/bin/env bash

aws logs put-metric-filter \
  --log-group-name nginx \
  --filter-name HTTPCode_nginx_2XX \
  --filter-pattern "\"status:2\""

aws logs put-metric-filter \
  --log-group-name nginx \
  --filter-name HTTPCode_nginx_4XX \
  --filter-pattern "\"status:4\""

aws logs put-metric-filter \
  --log-group-name nginx \
  --filter-name HTTPCode_nginx_5XX \
  --filter-pattern "\"status:5\""

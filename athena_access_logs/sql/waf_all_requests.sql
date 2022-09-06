SELECT 
    date_format(from_unixtime(timestamp / 1000e0), '%Y-%m-%d %T') as time, 
    httprequest.httpmethod, httprequest.uri, action, httprequest
FROM "${database_name}"."${table_name}"
WHERE httprequest.uri <> '/healthcheck'
ORDER BY time DESC;

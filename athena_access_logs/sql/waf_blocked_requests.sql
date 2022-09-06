WITH data AS (
    SELECT
        date_format(from_unixtime(timestamp / 1000e0), '%Y-%m-%d') as time, header.value as host, action,
        terminatingruleid,
        httprequest.clientip, httprequest.country, httprequest.httpmethod, httprequest.uri
    FROM "${database_name}"."${table_name}"
    CROSS JOIN UNNEST(httprequest.headers) AS t(header)
    WHERE lower(header.name) = 'host'
    AND action = 'BLOCK'
)
SELECT
    min(time) as start_date, max(time) as end_date,
    count(*) as num,
    clientip, country,
    array_join(array_agg(distinct terminatingruleid), ', ') as terminatingruleid,
    host,
    array_join(array_agg(distinct uri), ', ') as uris
FROM data
GROUP BY clientip, country, host
ORDER BY end_date DESC

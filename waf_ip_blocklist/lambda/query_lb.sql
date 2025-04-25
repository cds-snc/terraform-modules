-- List of IP addresses that have triggered 4xx HTTP responses
SELECT
    client_ip,
    COUNT(*) as count
FROM
    {log_table}
WHERE
    (
        elb_status_code = 403
        OR target_status_code LIKE '4__'
    )
    AND target_status_code NOT IN ({skip_list})
    AND from_iso8601_timestamp(time) >= date_add('day', -1, current_timestamp)
GROUP BY
    client_ip
HAVING COUNT(*) > {block_threshold}
ORDER BY count DESC
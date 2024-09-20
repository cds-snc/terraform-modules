-- List of IP addresses that have been blocked by WAF
SELECT 
    httpRequest.clientIp,
    COUNT(*) as count
FROM 
    {waf_logs_table}
WHERE 
    action = 'BLOCK'
    AND terminatingruleid NOT IN ({waf_rule_ids_skip}) 
    AND from_unixtime(timestamp/1000) >= date_add('day', -1, current_timestamp)
GROUP BY 
    httpRequest.clientIp
HAVING COUNT(*) > {block_threshold}
ORDER BY count DESC
WITH log_data AS (
    SELECT logEvents 
    FROM "${database_name}"."${table_name}"
    WHERE 
        log_group = 'LOG_GROUP_NAME' 
        AND year = 'YYYY' 
        AND month = 'MM' 
        AND day = 'DD'
)
SELECT 
    from_unixtime(log_event.timestamp / 1000.0) AS log_time,
    log_event.message AS log_message
FROM 
    log_data
CROSS JOIN 
    UNNEST(logEvents) AS t(log_event);
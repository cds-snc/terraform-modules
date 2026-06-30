CREATE EXTERNAL TABLE `${database_name}.${table_name}` (
    messageType string,
    owner string,
    logStream string,
    subscriptionFilters array<string>,
    logEvents array<struct<id: string, timestamp: bigint, message: string>>
)
PARTITIONED BY (
    log_group string,
    year string,
    month string,
    day string
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
LOCATION 's3://${bucket_name}/logs/'
TBLPROPERTIES (
    'has_encrypted_data'='false',
    'projection.enabled'='true',
    'projection.log_group.type'='injected',
    'projection.year.type'='date',
    'projection.year.range'='2020,2040',
    'projection.year.format'='yyyy',
    'projection.month.type'='integer',
    'projection.month.range'='01,12',
    'projection.month.digits'='2',
    'projection.day.type'='integer',
    'projection.day.range'='01,31',
    'projection.day.digits'='2',
    'storage.location.template'='s3://${bucket_name}/logs/log_group=$${log_group}/year=$${year}/month=$${month}/day=$${day}/'
);
CREATE EXTERNAL TABLE IF NOT EXISTS `${database_name}.${table_name}`(
  `timestamp` bigint, 
  `formatversion` int, 
  `webaclid` string, 
  `terminatingruleid` string, 
  `terminatingruletype` string, 
  `action` string, 
  `terminatingrulematchdetails` array<struct<conditiontype:string,sensitivitylevel:string,location:string,matcheddata:array<string>>>, 
  `httpsourcename` string, 
  `httpsourceid` string, 
  `rulegrouplist` array<struct<rulegroupid:string,terminatingrule:struct<ruleid:string,action:string,rulematchdetails:array<struct<conditiontype:string,sensitivitylevel:string,location:string,matcheddata:array<string>>>>,nonterminatingmatchingrules:array<struct<ruleid:string,action:string,overriddenaction:string,rulematchdetails:array<struct<conditiontype:string,sensitivitylevel:string,location:string,matcheddata:array<string>>>,challengeresponse:struct<responsecode:string,solvetimestamp:string>,captcharesponse:struct<responsecode:string,solvetimestamp:string>>>,excludedrules:string>>, 
  `ratebasedrulelist` array<struct<ratebasedruleid:string,limitkey:string,maxrateallowed:int>>, 
  `nonterminatingmatchingrules` array<struct<ruleid:string,action:string,rulematchdetails:array<struct<conditiontype:string,sensitivitylevel:string,location:string,matcheddata:array<string>>>,challengeresponse:struct<responsecode:string,solvetimestamp:string>,captcharesponse:struct<responsecode:string,solvetimestamp:string>>>, 
  `requestheadersinserted` array<struct<name:string,value:string>>, 
  `responsecodesent` string, 
  `httprequest` struct<clientip:string,country:string,headers:array<struct<name:string,value:string>>,uri:string,args:string,httpversion:string,httpmethod:string,requestid:string,fragment:string,scheme:string,host:string>,
  `labels` array<struct<name:string>>, 
  `captcharesponse` struct<responsecode:string,solvetimestamp:string,failurereason:string>, 
  `challengeresponse` struct<responsecode:string,solvetimestamp:string,failurereason:string>, 
  `ja3fingerprint` string, 
  `ja4fingerprint` string, 
  `oversizefields` string, 
  `requestbodysize` int, 
  `requestbodysizeinspectedbywaf` int)
  PARTITIONED BY ( 
   `hour` string)
ROW FORMAT SERDE 
  'org.openx.data.jsonserde.JsonSerDe' 
STORED AS INPUTFORMAT 
  'org.apache.hadoop.mapred.TextInputFormat' 
OUTPUTFORMAT 
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  '${bucket_location}'
TBLPROPERTIES (
  'projection.enabled'='true',
  'projection.hour.format'='yyyy/MM/dd/HH',
  'projection.hour.interval'='1',
  'projection.hour.interval.unit'='hours',
  'projection.hour.range'='2020/01/01/00,NOW',
  'projection.hour.type'='date',
  'storage.location.template'='${bucket_location}/${hour}')

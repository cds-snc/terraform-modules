CREATE EXTERNAL TABLE `${database_name}.${table_name}`(
  `timestamp` bigint, 
  `formatversion` int, 
  `webaclid` string, 
  `terminatingruleid` string, 
  `terminatingruletype` string, 
  `action` string, 
  `terminatingrulematchdetails` array<
                                    struct<
                                        conditiontype:string,
                                        location:string,
                                        matcheddata:array<string>
                                           >
                                    >, 
  `httpsourcename` string, 
  `httpsourceid` string, 
  `rulegrouplist` array<
                      struct<
                          rulegroupid:string,
                          terminatingrule:struct<
                                              ruleid:string,
                                              action:string,
                                              rulematchdetails:string
                                                >,
                          nonterminatingmatchingrules:array<string>,
                          excludedrules:string
                            >
                       >, 
 `ratebasedrulelist` array<
                         struct<
                             ratebasedruleid:string,
                             limitkey:string,
                             maxrateallowed:int
                               >
                          >, 
  `nonterminatingmatchingrules` array<
                                    struct<
                                        ruleid:string,
                                        action:string
                                          >
                                     >, 
  `requestheadersinserted` string, 
  `responsecodesent` string, 
  `httprequest` struct<
                    clientip:string,
                    country:string,
                    headers:array<
                                struct<
                                    name:string,
                                    value:string
                                      >
                                 >,
                    uri:string,
                    args:string,
                    httpversion:string,
                    httpmethod:string,
                    requestid:string
                      >, 
  `labels` array<
               struct<
                   name:string
                     >
                >, 
  `captcharesponse` struct<
                        responsecode:string,
                        solvetimestamp:string,
                        failureReason:string
                          > 
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
STORED AS INPUTFORMAT 'org.apache.hadoop.mapred.TextInputFormat'
OUTPUTFORMAT 'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION '${bucket_location}'
/* 
* # RDS Activity Stream
*
* Creates an RDS activity stream that has its events written to an S3 bucket for auditting.  By default the activity stream is [asynchronous to prioritize database performance](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/DBActivityStreams.Overview.html#DBActivityStreams.Overview.sync-mode). 
* 
* This is accomplished with a Kinesis Firehose that reads from the activity stream and uses a Lambda function to decrypts the records before they are written to the bucket.  The design is based on [a recommended AWS architecture](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/DBActivityStreams.Overview.html#DBActivityStreams.Overview.how-they-work).
* 
* ⚠ **Note:** Docker is required for the `terraform apply` to download the Lambda function's Python dependencies.  
*/

resource "aws_kms_key" "activity_stream" {
  description = "Encrypts the ${var.rds_stream_name} RDS activity stream"
  tags        = local.common_tags
}

resource "aws_rds_cluster_activity_stream" "activity_stream" {
  resource_arn = var.rds_cluster_arn
  mode         = var.activity_stream_mode
  kms_key_id   = aws_kms_key.activity_stream.key_id
}

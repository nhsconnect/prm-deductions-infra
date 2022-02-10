In athena you need to create a table with the script on below if it's not exist

```
CREATE EXTERNAL TABLE IF NOT EXISTS `<db-name>`.`<table-name>` (
`bill_billing_period_start_date` timestamp,
`bill_billing_period_end_date` timestamp, `product_product_name` string, `line_item_resource_id` string, `resource_tags_user_created_by` string, `line_item_line_item_description` string, `pricing_public_on_demand_cost` double
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe' WITH SERDEPROPERTIES ( 'serialization.format' = '1'
) LOCATION 's3://repo-aws-cost-analyzer/aws-cost/aws-cost-report/aws-cost-report/year=2022/month=1'
TBLPROPERTIES ('has_encrypted_data'='false')
```
repo-aws-cost-analyzer is the bucket name in dev that we could find the detailed report and aws-cost/aws-cost-report/ is the specific path for it 

After creating of the db and table now we can query that with the script on below  to produce the cost and service specific result.
```
SELECT  product_product_name AS ServiceName, ROUND (SUM (pricing_public_on_demand_cost), 3) as Cost FROM "repo-aws-cost"."aws-cost"
WHERE (line_item_resource_id like '%nems%'
OR line_item_resource_id like '%pds%'
OR line_item_resource_id like '%suspension%'
OR line_item_resource_id like '%mesh%')
AND bill_billing_period_start_date = DATE('2022-01-01') <yyyy-mm-dd> //First day of the any month that you want to see the costs
AND bill_billing_period_end_date = DATE('2022-02-01') <yyyy-mm-dd>  //First day of the any month that you want to see the costs
GROUP BY product_product_name
ORDER BY Cost DESC
```

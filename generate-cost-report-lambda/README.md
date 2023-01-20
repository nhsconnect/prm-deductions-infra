#Generate AWS Cost and Usage Report

##What are AWS Cost and Usage Reports?
The AWS Cost and Usage Reports (AWS CUR) contains the most comprehensive set of cost and usage data available. You can use Cost and Usage Reports to publish your AWS billing reports to an Amazon Simple Storage Service (Amazon S3) bucket that you own. AWS updates the report in your bucket once a day in comma-separated value (CSV) format.

AWS Cost and Usage Reports tracks your AWS usage and provides estimated charges associated with your account. Each report contains line items for each unique combination of AWS products, usage type, and operation that you use in your AWS account. You can customize the AWS Cost and Usage Reports to aggregate the information either by the hour, day, or month.

AWS Cost and Usage Reports can do the following:
* Deliver report files to your Amazon S3 bucket
* Update the report up to three times a day
* Create, retrieve, and delete your reports using the AWS CUR API Reference

##Automated CUR  architecture diagram:
<img height="300" src="automated-cur-architecture.svg" width="500"/>


##Automated AWS Cost and Usage Monthly Report
###AWS Components configured in the automation process:
* AWS Billing Service 
   - The Billing Service generates a monthly report in Amazon S3 
   - This is configured manually via the AWS console
* AWS S3  
   - The CUR report is stored in the S3 bucket path as configured in the Billing Service.
   - Athena query results are stored in the S3 bucket in the output location.
   - This is configured via Terraform
* AWS Glue 
    - Glue crawler is created using Terraform and is scheduled to run end of every month.
    - The Glue crawler crawls over the S3 path, looks for any change in the folders and then creates the cost report table.
    - This is configured via Terraform
* AWS Athena 
    - We use Athena service to query the cost report which is populated in the Glue table. 
    - This is run by the Lambda function.
* AWS SES   
    - We use SES to email the reports to the capacity management team.
    - We also email to the support team in case of any failures.
    - This is configured via Terraform for the sender email address.
* AWS Lambda   
   - Lambda function generates the cost report and sends it to the capacity management team.
   - Email IDs are configured as a manual user input in the SSM parameters.
   - Lambda function is a Python script which is deployed via GoCD.
* AWS CloudWatch EventBridge Rule   
    - An EventBridge rule invokes the Lambda function last day of every month.
    - This is configured via Terraform
* AWS IAM   
  - Necessary IAM permissions are provided for the above services using Terraform.

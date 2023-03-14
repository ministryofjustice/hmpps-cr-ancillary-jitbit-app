# Sandbox environment deployments

# In progress - still to do...

Dependencies
- Connection string passed into helm deployment 

Useful commands
helm create jitbit
helm lint jitbit
helm install jitbit -n $nsjdev --dry-run


helm diff upgrade jitbit jitbit -n $nsjdev

helm upgrade jitbit jitbit -n $nsjdev \
  --set database.dbConnectionString="user id=BLAH;data source=BLAH.eu-west-2.rds.amazonaws.com;initial catalog=BLAH;password=BLAH" \
  --set image.tag=BLAH



# S3
## Uploads
bucketName=<bucketName>
aws s3 cp docker/app/HelpDesk

## Downloads
Copy delius-jitbit files from mod platform bucket
```
aws s3 cp /path/to/app/HelpDesk_10_14 <s3 URI>/app --dryrun
```
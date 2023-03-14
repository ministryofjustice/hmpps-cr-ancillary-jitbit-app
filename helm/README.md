- [Cloud Platform environment deployment](#cloud-platform-environment-deployment)
  - [Deployment process](#deployment-process)
  - [Secrets](#secrets)
  - [Dependencies](#dependencies)
    - [Jitbit app artefacts held in S3](#jitbit-app-artefacts-held-in-s3)
      - [S3 bucket directory structure](#s3-bucket-directory-structure)
      - [Useful commands and operations](#useful-commands-and-operations)
    - [Database and connection string](#database-and-connection-string)
      - [Useful commands and operations](#useful-commands-and-operations-1)
  - [Useful links](#useful-links)

# Cloud Platform environment deployment
This directory contains a helm chart representing the package that can be deployed to the Cloud Platform to support a Jitbit sandbox/dev environment.
The objective with this helm chart, and the [Github action workflow](../.github/workflows/cloud-platform-sandbox-build-deploy.yml) that deploys it, is that it can be easily deployable to be able to offer the capability out to self-service users.

## Deployment process
At a high-level, the deployment process is
  1. Self-service user runs the [Github action workflow](https://github.com/ministryofjustice/hmpps-cr-ancillary-jitbit-app/actions/workflows/cloud-platform-sandbox-build-deploy.yml), selecting the Jitbit version number to deploy
  2. The workflow performs the following tasks
     1. Check if the docker image representing the Jitbit app version is already in the AWS ECR repository. If it is, there is no need to continue to build/tag/push the image. If not, then, continue to
        1. Download s3 files representing Jitbit app artefacts from the vendor
        2. Build, tag and push the docker image to the ECR repository
     2. In all cases, deploy the selected Jitbit app version to the Cloud Platform dev environment
  
## Secrets
Kubernetes secrets hold information relating to
- Database connection string
- IAM user details associated with the S3 buckets holding the Jitbit app files and the app artefacts
- Jitbit AWS ECR repo holding docker images for the Jitbit versions
- The kubernetes service account used by the Github action workflow to authenticate to the kubernetes namespace to perform deployments

See [this guidance page](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/deploying-an-app/add-secrets-to-deployment.html#decoding-a-secret) for information on how to work with, and retrieve secrets

## Dependencies
There are a number of dependencies that need to be in place for the above workflow to succeeed. These are as followed

### Jitbit app artefacts held in S3
These are the artefacts supplied by the vendor that are pulled down and copied in the docker image during the build process. If a version of the application is wanting to be deployed but the files are not in the S3 bucket, then the files need to be added. The directory structure of the bucket should be adhered to to ensure that the docker build process can successfully identify the correct version and download the files.

#### S3 bucket directory structure
- ROOT
  - app
    - HelpDesk_10_14

New directories of the app should sit alongside HelpDesk_10_14, following the same naming convention.

#### Useful commands and operations
```
# Use AWS CLI to show bucket contents. Replace BUCKET_NAME with the name retrievable from the jitbit app artefacts kubernetes secret
aws s3 ls s3://BUCKET_NAME/app
```

```
# Upload contents to the S3 bucket, e.g. in the case of a new version. Examples below based on upload of 10_14.
# Example uses --dryrun to show what it would upload without performing it. Remove this option to actually perform the upload
aws s3 sync /path/to/app/HelpDesk_10_14/ s3://cloud-platform-1234567890/app/HelpDesk_10_14/ --dryrun
```


### Database and connection string
Jitbit employs an RDS MSSQL database for its data storage. The app requires a connection string in the format below in order to connect
```
user id=change_me;data source=cloud-platform-1234567890.abcde12345.eu-west-2.rds.amazonaws.com;initial catalog=change_me;password=change_me
```
This connection string is passed to the application in the form of an environment variable, that overrides the contents of appsetting.json.
The value for the environment variable is retrieved from a kubernetes secret. The contents of the secret are passed in as a SET option in the helm cli. In turn, the ultimate source of the secret is held as a Github action secret.

#### Useful commands and operations
In order to connect to the MSSQL database, see Cloud Platform guidance [here](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/other-topics/rds-external-access.html). The method used is based on port-forwarding, allowing connections to be made from a source workstation through to the private RDS database instance. Once connected, any MSSQL-compatible SQL client can be used to administer the database.

```
# An example is given below, with the need to replace NAMESPACE,  RDS_DATABASE_INSTANCE_ENDPOINT, USERNAME, PASSWORD as appropriate
# The second kubectl command creates a background task representing the creation of the connection
kubectl -n NAMESPACE run port-forward-pod --image=ministryofjustice/port-forward --port=1433 --env="REMOTE_HOST=RDS_DATABASE_INSTANCE_ENDPOINT" --env="LOCAL_PORT=1433" --env="REMOTE_PORT=1433"
kubectl -n NAMESPACE port-forward port-forward-pod 1433:1433 > /dev/null 2>&1 &
jobs # View background process created by command above
nc -zv 127.0.0.1 1433
> Connection to 127.0.0.1 port 1433 [tcp/ms-sql-s] succeeded!
sqlcmd -S 127.0.0.1 -U USERNAME -P PASSWORD -q "select name from sys.databases;"
sqlcmd -S 127.0.0.1 -U USERNAME -P PASSWORD -i /path/to/script.sql
```

## Useful links
- Accessing the AWS console [link](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/accessing-the-cloud-console.html)
- Connecting to the Cloud Platform Kubernetes cluster [link](https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/kubectl-config.html). This also includes details of how to install kubectl.

# Useful scripts during the POC

## Docker commands

docker build -t jitbit:0.2 docker  
docker run -d -p 5000:5000 jitbit:0.2
aws ecr list-images --repository-name hmpps-migration/hmpps-community-rehabilitation-ancilliary-jitbit-dev-ecr

docker tag jitbit:0.2 \<cloud platform account id\>.dkr.ecr.eu-west-2.amazonaws.com/hmpps-migration/hmpps-community-rehabilitation-ancilliary-jitbit-dev-ecr:0.2

docker push \<cloud platform account id\>.dkr.ecr.eu-west-2.amazonaws.com/hmpps-migration/hmpps-community-rehabilitation-ancilliary-jitbit-dev-ecr:0.2

## K8s secret commands

cat kubernetes/files/appsettings.json | base64

## MSSQL access

kubectl -n $nsjdev run port-forward-pod --image=ministryofjustice/port-forward --port=1433 --env="REMOTE_HOST=\<rds endpoint\>" --env="LOCAL_PORT=1433" --env="REMOTE_PORT=1433"
kubectl -n $nsjdev port-forward port-forward-pod 1433:1433 > /dev/null 2>&1 &
sqlcmd -h 127.0.0.1 -U \<username\> -P \<password\>

## Port forward to pod to access web site locally

kubectl -n $nsjdev port-forward jitbit-pod 5000:5000 > /dev/null 2>&1 &

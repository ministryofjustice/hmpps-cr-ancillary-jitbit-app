Dependencies
- Connection string passed into helm deployment 

Useful commands
helm create jitbit
helm lint jitbit
helm install jitbit -n $nsjdev --dry-run


helm diff upgrade jitbit jitbit -n $nsjdev



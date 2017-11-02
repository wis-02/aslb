# remove Stacks

docker stack rm proxy

docker stack rm monitor

docker stack rm jenkins

docker stack rm web

# remove secrets
docker secret rm alert_manager_config 
docker secret rm jenkins-user
docker secret rm jenkins-pass

# remove networks
docker network rm monitor
docker network rm proxy



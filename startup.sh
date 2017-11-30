# Setup Cluster


eval $(docker-machine env default)

#docker swarm init --advertise-addr $(docker-machine ip default)

TOKEN=$(docker swarm join-token -q manager)

docker node ls


# Deploy Proxy
docker network create -d overlay monitor

docker network create -d overlay proxy

#docker stack deploy -c proxylc.yml proxy
docker stack deploy -c proxy.yml proxy
read -n1 -r -p "Press any key to continue..." key
docker stack ps proxy


# Deploy Monitor

echo "route:
  group_by: [service,scale]
  repeat_interval: 3m
  group_interval: 3m
  receiver: 'slack'
  routes:
  - match:
      service: 'web_server'
      scale: 'up'
    receiver: 'jenkins-go-demo_main-up'
  - match:
      service: 'web_server'
      scale: 'down'
    receiver: 'jenkins-go-demo_main-down'
  - match:
      service: 'web'
      scale: 'up'
    receiver: 'jenkins-web-up'
  - match:
      service: 'web'
      scale: 'down'
    receiver: 'jenkins-web-down'
	
receivers:
  - name: 'slack'
    slack_configs:
      - send_resolved: true
        title: '[{{ .Status | toUpper }}] {{ .GroupLabels.service }} service is in danger!'
        title_link: 'http://$(docker-machine ip default)/monitor/alerts'
        text: '{{ .CommonAnnotations.summary}}'
        api_url: 'https://hooks.slack.com/services/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'
  - name: 'jenkins-go-demo_main-up'
    webhook_configs:
      - send_resolved: false
        url: 'http://$(docker-machine ip default)/jenkins/job/service-scale/buildWithParameters?token=DevOps22&service=web_server&scale=1'
  - name: 'jenkins-go-demo_main-down'
    webhook_configs:
      - send_resolved: false
        url: 'http://$(docker-machine ip default)/jenkins/job/service-scale/buildWithParameters?token=DevOps22&service=web_server&scale=-1'
  - name: 'jenkins-web-up'
    webhook_configs:
      - send_resolved: false
        url: 'http://$(docker-machine ip default)/jenkins/job/service-scale/buildWithParameters?token=DevOps22&service=web&scale=1'
  - name: 'jenkins-web-down'
    webhook_configs:
      - send_resolved: false
        url: 'http://$(docker-machine ip default)/jenkins/job/service-scale/buildWithParameters?token=DevOps22&service=web&scale=-1'
" | docker secret create alert_manager_config -

read -n1 -r -p " Wait bit and then press any key to continue..." key

DOMAIN=$(docker-machine ip default) docker stack deploy -c \
monitor.yml monitor
read -n1 -r -p "Press any key to continue..." key
docker stack ps -f desired-state=running monitor

sleep 5

# Deploy Jenkins


echo "admin" | docker secret create jenkins-user -
read -n1 -r -p "Press any key to continue..." key
echo "admin" | docker secret create jenkins-pass -
read -n1 -r -p "Press any key to continue..." key
export SLACK_IP=54.192.228.31

echo $SLACK_IP


docker stack deploy -c jenkins.yml jenkins
read -n1 -r -p "Press any key to continue..." key
docker stack ps jenkins

docker stack deploy -c web.yml web
read -n1 -r -p "Press any key to continue..." key
# Metrics
# Auto-Scaling
docker stack ps -f desired-state=running web
read -n1 -r -p "Press any key to continue..." key
echo "http://$(docker-machine ip default)/monitor"
echo "http://$(docker-machine ip default)/monitor/targets"
echo "http://$(docker-machine ip default)/monitor/graph"
echo "http://$(docker-machine ip default)/monitor/alerts"
# Click the *Run* button > it fails
echo "http://$(docker-machine ip default)/jenkins/job/service-scale/configure"
echo "http://$(docker-machine ip default)/jenkins/blue/organizations/jenkins/service-scale/activity"




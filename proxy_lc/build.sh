# build nginx 
 docker build -t vfarcic/docker-flow-proxy:${TAG:-latest} .
 docker tag vfarcic/docker-flow-proxy:${TAG:-latest} localhost:5000/haproxy_lc

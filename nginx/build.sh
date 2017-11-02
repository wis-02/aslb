# build nginx 
 docker build -t ndegory/nginx-prometheus .
 docker tag ndegory/nginx-prometheus localhost:5000/mynginx

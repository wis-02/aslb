# build jenkins scale image
 docker build -t vfarcic/jenkins .
 docker tag vfarcic/jenkins localhost:5000/jenkins
 #docker push localhost:5000/jenkins

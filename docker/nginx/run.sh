DOCKER_CONTAINER_HASH=$(docker ps -a -f "name=nginx" -q)

docker stop $DOCKER_CONTAINER_HASH
docker rm $DOCKER_CONTAINER_HASH

docker run --name nginx \
        -v $(pwd)/../../init.sh:/usr/share/nginx/html/index.txt \
        -p 80:80 \
        -d 48763/nginx:1.12.2
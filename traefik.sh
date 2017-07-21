sudo docker service create \
--name proxy \
--constraint 'node.role==manager' \
--publish 80:80 \
--publish 8080:8080 \
--mount type=bind,source=/var/run/docker.sock,target=/var/run/docker.sock \
--network swarm_network \
traefik:camembert \
--docker \
--docker.swarmmode \
--docker.domain=35.184.0.178 \
--docker.watch \
--logLevel=DEBUG \
--web


sudo docker service rm ${COMPONENT_NAME}


sudo docker service create \
--name springrestapi \
--label 'traefik.port=8080' \
--label 'traefik.docker.network=swarm_network' \
--label 'traefik.backend.loadbalancer.swarm=true' \
--network swarm_network \
--label traefik.frontend.rule="Path:/springrest/;PathPrefixStrip:/springrest/" \
chakri442/springrestapi:53

docker service create \
--name api \
--label 'traefik.port=5000' \
--network traefik-net \
jmkhael/myservice:0.0.1

http://0.0.0.0/springrest/SpringBootRestApi/api/user/

35.184.0.178

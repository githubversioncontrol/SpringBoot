dzdo mkdir -m a=rwx -p /aflac/Compose/${COMPONENT_NAME}
dzdo chmod 777 -R /aflac/Compose/
dzdo docker login --username=$dockeruser --password=$dockerpass ${DTR_REGISTRY}
dzdo docker pull ${DTR_REGISTRY}/admin/${COMPONENT_NAME}:${BUILD_NUMBER}

if [ ${ServiceType} == "WEB_HTTPS" ]; then
verifyssl="https"
else
verifyssl="http"
fi

cat >/aflac/Compose/${COMPONENT_NAME}/${COMPONENT_NAME}_compose.yml <<EOL
version: '3'
services:
  ${COMPONENT_NAME}:
    image: ${DTR_REGISTRY}/admin/${COMPONENT_NAME}:${BUILD_NUMBER}
    logging:
      driver: splunk
      options:
        splunk-token: "3F637903-7B25-40DB-91E5-1240E4BDF916"
        splunk-url: "https://icnsoa01:8088"
        splunk-insecureskipverify: "true"
    environment:
     - ROUTINGSLIPAPPCONFIGHOST=${ROUTINGSLIPAPPCONFIGHOST}
     - APPCONFIGURL=${APPCONFIGURL}
     - keyPassword=${KeyStorePassword}
     - keyStore=${KeyStore}
     - storePassword=${StorePassword}
     - trustStore=${TrustStore}
     - trustPassword=${TrustStorePassword}
     - MongoServer=${MongoServer}
     - MongoPort=${MongoPort}
     - ServiceNamePostFix=${COMPONENT_Postfix}
     - ROUTINGSLIPURL=${ROUTINGSLIPURL} 
    deploy:
      placement:
        constraints:
          - engine.labels.eibinstance == eibnode
      mode: replicated
      replicas: ${NUMBER_OF_INSTANCE}
      labels:
        - "traefik.port=8080"
        - "traefik.docker.network=swarm_network"
        - "traefik.frontend.rule=Host:eib-dev.nt.lab.com, www.eib-dev.nt.lab.com;PathPrefix:/${COMPONENT_NAME}/;PathPrefixStrip:/${COMPONENT_NAME}/"
      restart_policy:
       condition: on-failure
       window: 60s
    networks:
     - default
networks:
  default:
    external:
      name: swarm_network
EOL


cd /aflac/Compose/${COMPONENT_NAME}

dzdo docker stack deploy --with-registry-auth --compose-file=${COMPONENT_NAME}_compose.yml swarm

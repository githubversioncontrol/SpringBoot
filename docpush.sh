http_code=0
	 http_code=$(curl -v \
               		--user $dockeruser:$dockerpass \
					--write-out %{http_code} --silent --output /dev/null \
                    --insecure \
                    -X GET https://$DTR_REGISTRY/api/v0/repositories/admin/$COMPONENT_NAME )
			 echo "RECEIVED HTTP CODE $http_code"
			
if echo "$http_code" | grep '200'; then
		
		echo "The repo already exist $http_code"
else
	result_code=$(curl -v \
               		--user $dockeruser:$dockerpass \
					--write-out %{http_code} --silent --output /dev/null \
                    --insecure \
                    -X POST https://$DTR_REGISTRY/api/v0/repositories/admin \
                    --data '{"name": "'"$COMPONENT_NAME"'"}' \
                    --header "Content-type: application/json" )
                    
                    
      if echo "$result_code" | grep '201'; then		
              echo "Successfully created the repo"
      else
          echo "Repo creation failed . error code: $result_code"
          exit 1
          
      fi

fi

 dzdo docker ps -a | awk '{ print $1,$2 }' | grep ${COMPONENT_NAME} | awk '{print $1 }' | xargs -I {} dzdo docker stop {}
 dzdo docker ps -a | awk '{ print $1,$2 }' | grep ${COMPONENT_NAME} | awk '{print $1 }' | xargs -I {} dzdo docker rm  -f {} 
dzdo docker tag ${COMPONENT_NAME}:${BUILD_NUMBER} ${DTR_REGISTRY}/admin/${COMPONENT_NAME}:${BUILD_NUMBER}

dzdo docker login --username=$dockeruser --password=$dockerpass ${DTR_REGISTRY}

dzdo docker push ${DTR_REGISTRY}/admin/${COMPONENT_NAME}:${BUILD_NUMBER}

if [ ${COMPONENT_NAME} != "appconfigurationcontroller" ]; then
dzdo docker tag ${COMPONENT_NAME}:${BUILD_NUMBER} intdtr/admin/${COMPONENT_NAME}:${BUILD_NUMBER}

dzdo docker login --username=$dockeruser --password=$dockerpass dtr-int.nt.lab.com

dzdo docker push intdtr/admin/${COMPONENT_NAME}:${BUILD_NUMBER}
fi

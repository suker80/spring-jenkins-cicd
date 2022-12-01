#!/usr/bin/env sh

# 현재 사용중인 포트를 확인한다.
RESPONSE=$(curl -s localhost:8080/actuator/health)
echo "> RESPONSE : "$RESPONSE

IS_ACTIVE=$(echo ${RESPONSE} | grep 'UP' | wc -l)
echo "> IS_ACTIVE"$IS_ACTIVE
if [ $IS_ACTIVE -eq 1 ];
then
    IDLE_PORT=8081
    IDLE_PROFILE=GREEN
    CURRENT_PORT=8080
    CURRENT_PROFILE=BLUE

else
    IDLE_PORT=8080
    IDLE_PROFILE=BLUE
    CURRENT_PORT=8081
    CURRENT_PROFILE=GREEN
fi

# 배포했던 서버들이 전부 성공적으로 빌드가 되었는지 확인한다.
SERVERS=(`cat servers`)
# 서버들의 개수
TOTAL_SERVER=${#SERVERS[@]}
# 임시로 Spring 서버들의 응답을 저장할 파일을 하나 만든다.
true > servers_response

for server in ${SERVERS[@]} ; do
  scp ${server}:RESULT .
  cat RESULT >> servers_response
if [ "$TOTAL_SERVER" -eq "$(grep -c "OK" servers_response)" ]; then
  echo "> 정상 배포 완료"
  echo "set \$ACTIVE_PORT $IDLE_PORT" | sudo tee /etc/nginx/site-avaliables/port.conf
  echo "> nginx 재시작"
  sudo systemctl reload nginx
    
fi
done

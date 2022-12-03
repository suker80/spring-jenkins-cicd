#!/bin/zsh

HUB_REPOSITORY=suker800/spring-cicd
# 현재 사용하고 있는 포트와 유휴 상태인 포트를 체크한다.
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

echo "> 다음 사용할 포트" $IDLE_PORT
echo "> 다음 사용할 프로필 " $IDLE_PROFILE

# 도커 허브에서 PULL을 한다.
sudo docker pull $HUB_REPOSITORY

# 도커를 통해 컨테이너를 실행시킨다.
echo "도커 실행 " docker run -p $IDLE_PORT:$IDLE_PORT -e "-USE_PROFILE=$IDLE_PROFILE" $HUB_REPOSITORY > nohup.out 2>&1 &

nohup docker run -p $IDLE_PORT:$IDLE_PORT -e "-USE_PROFILE=$IDLE_PROFILE" $HUB_REPOSITORY > nohup.out 2>&1 &

echo "> 10초 기다렸다가 Health Check"

for i in {1..10} ;
do
echo "> Health Check까지 " "$(( 10 - "$i"))"초 남음

sleep 1
done

for RETRY in {1..10}
do
    RESPONSE=$(curl -s localhost:8080/actuator/health)
    IS_ACTIVE=$(echo ${RESPONSE} | grep 'UP' | wc -l)

    if [ $IS_ACTIVE -ge 1 ]; then
      echo "> Health Check Success"
      echo "OK" > RESULT
      break
    else
      echo "> Health Check Failed"
      echo "> Health Check RESPONSE : " $RESPONSE
    fi
    
    if [ $RETRY -eq 10 ]; then
        echo "> Health Check Failed"
        echo "FAIL" > RESULT
    fi
done

# 마지막으로 실행중이던 포트 종료
docker kill $(docker ps -qf expose=$CURRENT_PORT) 2> /dev/null || echo "현재 실행중인 서버가 없습니다. CURRENT_PORT: $CURRENT_PORT"


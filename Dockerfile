FROM openjdk:11
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} app.jar
ENV USE_PROFILE local
ENTRYPOINT ["java","-jar","-Dspring.profiles.active=${USE_PROFILE}","/app.jar"]
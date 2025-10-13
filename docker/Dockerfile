FROM openjdk:22-jdk-slim
WORKDIR /app
COPY target/*.jar app.jar
ENTRYPOINT ["java","-jar","/app/app.jar"]docker --version
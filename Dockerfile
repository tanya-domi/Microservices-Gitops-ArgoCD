FROM eclipse-temurin:21-jdk AS builder

WORKDIR /home/petclinic/

COPY . .

COPY ./target/spring-petclinic-3.4.0-SNAPSHOT.jar .

# Runtime stage
FROM eclipse-temurin:21-jre

ARG PROFILE=dev
ARG APP_VERSION=3.4.0

WORKDIR /home/petclinic/
COPY --from=builder /home/petclinic/target/*.jar /home/petclinic/.jar

EXPOSE 8080

ENV ACTIVE_PROFILE=${PROFILE}
ENV JAR_VERSION=${APP_VERSION}

ENV MYSQL_URL=jdbc:mysql://petclinic-mysql:3306/petclinic

CMD ["java", "-jar", "-Dspring.profiles.active=${ACTIVE_PROFILE} -Dspring.datasource.url=${MYSQL_URL} spring-petclinic-${JAR_VERSION}-SNAPSHOT.jar"]

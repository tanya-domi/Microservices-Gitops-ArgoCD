FROM eclipse-temurin:21-jdk AS builder

WORKDIR /app

COPY --chmod=0755 mvnw mvnw

COPY .mvn/ .mvn/

COPY ./mvnw spring-petclinic/pom.xml ./

RUN ./mvnw dependency:go-offline

COPY ./src ./src

#Build Application
RUN ./mvnw package -DskipTests

# Runtime stage
FROM eclipse-temurin:21-jre

ARG PROFILE=dev
ARG APP_VERSION=3.4.0

WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

ENV ACTIVE_PROFILE=${PROFILE}
ENV JAR_VERSION=${APP_VERSION}

ENV MYSQL_URL=jdbc:mysql://petclinic-mysql:3306/petclinic

CMD ["java", "-jar", "-Dspring.profiles.active=${ACTIVE_PROFILE} -Dspring.datasource.url=${MYSQL_URL} spring-petclinic-${JAR_VERSION}.jar"]

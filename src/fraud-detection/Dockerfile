FROM eclipse-temurin:17-jdk AS builder
WORKDIR /app

COPY ./src/fraud-detection/gradle/ ./gradle/
COPY ./src/fraud-detection/gradlew ./
COPY ./src/fraud-detection/settings.gradle.kts ./
COPY ./src/fraud-detection/build.gradle.kts ./
COPY ./src/fraud-detection/gradle.properties ./

RUN chmod +x ./gradlew

COPY ./pb ./src/main/proto
COPY ./src/fraud-detection/src/main ./src/main

RUN ./gradlew shadowJar --no-daemon

FROM eclipse-temurin:21-jre
WORKDIR /app

COPY --from=builder /app/build/libs/*-all.jar ./fraud-detection.jar

ENTRYPOINT ["java", "-jar", "./fraud-detection.jar"]
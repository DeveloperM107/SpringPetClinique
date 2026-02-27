FROM eclipse-temurin:17-jdk-jammy

WORKDIR /app

# Copier le jar
COPY target/spring-petclinic-2.1.0.BUILD-SNAPSHOT.jar app.jar

# ⚠️ IMPORTANT — copier le keystore
COPY src/main/resources/keystore.p12 keystore.p12

# Exposer le bon port HTTPS
EXPOSE 8443

ENTRYPOINT ["java","-jar","app.jar"]

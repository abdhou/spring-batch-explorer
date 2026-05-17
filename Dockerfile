FROM node:24.15.0-alpine AS frontend-build
WORKDIR /app/frontend
COPY frontend/ .
RUN npm install
RUN npm run build

FROM eclipse-temurin:25-jdk AS backend-build
WORKDIR /app/backend
COPY backend/ .
COPY --from=frontend-build \
    /app/frontend/dist/frontend/browser \
    src/main/resources/static

RUN ./mvnw clean package -DskipTests

FROM eclipse-temurin:25-jre-alpine AS runtime
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY --from=backend-build \
    /app/backend/target/*.jar \
    app.jar

RUN chown appuser:appgroup app.jar
USER appuser
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]

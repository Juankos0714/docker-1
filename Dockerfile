# Stage 1: Build
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app

# Copy pom.xml and download dependencies
COPY adso-/adso-/pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code and build
COPY adso-/adso-/src ./src
RUN mvn clean package -DskipTests -B

# Stage 2: Runtime
FROM eclipse-temurin:17-jre

WORKDIR /app

# Create non-root user for security
RUN groupadd -r spring && useradd -r -g spring spring
USER spring:spring

# Copy jar from build stage
COPY --from=build /app/target/*.jar app.jar

# Expose port
EXPOSE 3005

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:3005/actuator/health || exit 1

# Run application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]

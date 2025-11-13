# ADSO Spring Boot Application

Aplicación Spring Boot con autenticación JWT y gestión de productos, lista para desplegar en Azure.

## Características

- 🔐 Autenticación JWT
- 👥 Gestión de usuarios
- 📦 API REST para productos
- 🐳 Dockerizado y listo para Azure
- 🚀 Build optimizado con multi-stage Docker

## Inicio Rápido

### Ejecutar con Docker

```bash
# Construir y ejecutar con docker-compose
docker-compose up --build

# O construir manualmente
docker build -t adso-app .
docker run -p 3005:3005 adso-app
```

La aplicación estará disponible en: `http://localhost:3005`

### Ejecutar con Maven (desarrollo)

```bash
cd adso-/adso-
./mvnw spring-boot:run
```

## Despliegue en Azure

Para desplegar esta aplicación en Azure, consulta la guía detallada en [AZURE_DEPLOYMENT.md](./AZURE_DEPLOYMENT.md).

**Opciones de despliegue:**
- ☁️ Azure Container Instances (ACI) - Más simple
- 🌐 Azure App Service - Recomendado
- ⚙️ Azure Kubernetes Service (AKS) - Para producción

## API Endpoints

- `POST /api/auth/register` - Registrar usuario
- `POST /api/auth/login` - Iniciar sesión
- `GET /api/products` - Listar productos (requiere auth)
- `POST /api/products` - Crear producto (requiere auth)

## Estructura del Proyecto

```
.
├── Dockerfile                 # Configuración Docker multi-stage
├── docker-compose.yml         # Configuración Docker Compose
├── .dockerignore             # Archivos excluidos de Docker
├── AZURE_DEPLOYMENT.md       # Guía de despliegue en Azure
└── adso-/adso-/              # Código fuente Spring Boot
    ├── pom.xml               # Dependencias Maven
    └── src/
        └── main/
            ├── java/         # Código Java
            └── resources/    # Configuración
```

## Tecnologías

- Java 17
- Spring Boot 3.5.7
- Spring Security
- JWT (jsonwebtoken)
- Maven
- Docker

## Licencia

MIT

### Ejecutar con Docker

```bash
# Construir y ejecutar con docker-compose
docker-compose up --build

# O construir manualmente
docker build -t adso-app .
docker run -p 3005:3005 adso-app
```

La aplicación estará disponible en: `http://localhost:3005`

### Subir a Docker Hub

```bash
# Usando el script automatizado
./docker-hub-push.sh TU_USUARIO 1.0.0

# Ver guía completa
# Ver DOCKER_HUB.md para más detalles
```

### Ejecutar con Maven (desarrollo)

```bash
cd adso-/adso-
./mvnw spring-boot:run
```

## Despliegue

### Docker Hub
Sube tu imagen a Docker Hub para facilitar el despliegue:
- 📘 Guía completa: [DOCKER_HUB.md](./DOCKER_HUB.md)
- 🤖 CI/CD: GitHub Actions pre-configurado (funciona sin secrets, construye sin push)
- 🔐 Configura secrets para push automático: `DOCKER_USERNAME` y `DOCKER_PASSWORD`
- 💰 Gratis: Sin costo usando tier gratuito

### Azure
Para desplegar esta aplicación en Azure, consulta la guía detallada en [AZURE_DEPLOYMENT.md](./AZURE_DEPLOYMENT.md).

**Opciones de despliegue:**
- ☁️ Azure Container Instances (ACI) - Más simple
- 🌐 Azure App Service - Recomendado
- ⚙️ Azure Kubernetes Service (AKS) - Para producción
- 🐳 Desde Docker Hub - Más económico (sin ACR)

## API Endpoints

- `POST /api/auth/register` - Registrar usuario
- `POST /api/auth/login` - Iniciar sesión
- `GET /api/products` - Listar productos (requiere auth)
- `POST /api/products` - Crear producto (requiere auth)

## Estructura del Proyecto

```
.
├── Dockerfile                     # Configuración Docker multi-stage
├── docker-compose.yml             # Configuración Docker Compose
├── .dockerignore                  # Archivos excluidos de Docker
├── docker-hub-push.sh             # Script para subir a Docker Hub
├── AZURE_DEPLOYMENT.md            # Guía de despliegue en Azure
├── DOCKER_HUB.md                  # Guía de Docker Hub
├── .github/workflows/
│   └── docker-publish.yml         # CI/CD con GitHub Actions
└── adso-/adso-/                   # Código fuente Spring Boot
    ├── pom.xml                    # Dependencias Maven
    └── src/
        └── main/
            ├── java/              # Código Java
            └── resources/         # Configuración
```


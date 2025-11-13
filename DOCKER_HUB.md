# Guía para Subir a Docker Hub

Esta guía te ayudará a subir tu imagen Docker a Docker Hub para facilitar el despliegue.

## Prerrequisitos

- Docker instalado localmente
- Cuenta en [Docker Hub](https://hub.docker.com/) (gratis)

## Opción 1: Usando el Script Automatizado (Recomendado)

### Paso 1: Ejecutar el script
```bash
./docker-hub-push.sh TU_USUARIO_DOCKERHUB 1.0.0
```

Ejemplo:
```bash
./docker-hub-push.sh juankos0714 1.0.0
```

El script automáticamente:
- Te pedirá login en Docker Hub
- Construirá la imagen
- La taggeará correctamente
- La subirá a Docker Hub

---

## Opción 2: Pasos Manuales

### Paso 1: Login en Docker Hub
```bash
docker login
```

Te pedirá tu usuario y contraseña de Docker Hub.

### Paso 2: Construir la imagen
```bash
docker build -t TU_USUARIO/adso-app:latest .
```

Ejemplo:
```bash
docker build -t juankos0714/adso-app:latest .
```

### Paso 3: Tagear con versión (opcional)
```bash
docker tag TU_USUARIO/adso-app:latest TU_USUARIO/adso-app:1.0.0
```

### Paso 4: Subir a Docker Hub
```bash
docker push TU_USUARIO/adso-app:latest
docker push TU_USUARIO/adso-app:1.0.0
```

---

## Opción 3: Automatización con GitHub Actions (CI/CD)

Ya está configurado un workflow en `.github/workflows/docker-publish.yml` que automáticamente:
- Construye la imagen en cada push a main/master
- Sube la imagen a Docker Hub
- Crea tags automáticos basados en versiones

### Configurar Secrets en GitHub

1. Ve a tu repositorio en GitHub
2. Settings → Secrets and variables → Actions
3. Agrega estos secrets:
   - `DOCKER_USERNAME`: Tu usuario de Docker Hub
   - `DOCKER_PASSWORD`: Tu contraseña o token de Docker Hub

### Triggers del Workflow

El workflow se ejecuta automáticamente cuando:
- Haces push a `main` o `master`
- Creas un tag con formato `v*.*.*` (ejemplo: `v1.0.0`)
- Manualmente desde GitHub Actions

### Crear un release con tag:
```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

---

## Usar la Imagen desde Docker Hub

### Localmente
```bash
docker pull TU_USUARIO/adso-app:latest
docker run -p 3005:3005 TU_USUARIO/adso-app:latest
```

### Con docker-compose
Actualiza el `docker-compose.yml`:
```yaml
services:
  adso-app:
    image: TU_USUARIO/adso-app:latest  # En lugar de build: .
    ports:
      - "3005:3005"
```

---

## Desplegar desde Docker Hub a Azure

### Azure Container Instances
```bash
az container create \
  --resource-group adso-rg \
  --name adso-app \
  --image TU_USUARIO/adso-app:latest \
  --dns-name-label adso-app-unique \
  --ports 3005 \
  --cpu 1 \
  --memory 1
```

### Azure App Service
```bash
az webapp create \
  --resource-group adso-rg \
  --plan adso-plan \
  --name adso-app-unique \
  --deployment-container-image-name TU_USUARIO/adso-app:latest

az webapp config appsettings set \
  --resource-group adso-rg \
  --name adso-app-unique \
  --settings WEBSITES_PORT=3005
```

### Azure Kubernetes Service
Actualiza el `deployment.yaml`:
```yaml
spec:
  containers:
  - name: adso-app
    image: TU_USUARIO/adso-app:latest
    ports:
    - containerPort: 3005
```

---

## Ventajas de Docker Hub

✅ **Público o Privado**: Repositorios gratuitos públicos, privados de pago
✅ **Rápido**: Descargas optimizadas desde múltiples ubicaciones
✅ **CI/CD**: Integración fácil con GitHub Actions
✅ **Versionado**: Múltiples tags para diferentes versiones
✅ **Sin ACR**: No necesitas Azure Container Registry (ahorra costos)

---

## Mejores Prácticas

### 1. Usar Tags Semánticos
```bash
docker build -t TU_USUARIO/adso-app:1.0.0 .
docker build -t TU_USUARIO/adso-app:latest .
```

### 2. Documentar en Docker Hub
Después de subir, agrega descripción en Docker Hub:
- Ve a https://hub.docker.com/r/TU_USUARIO/adso-app
- Edita la descripción
- Agrega instrucciones de uso

### 3. Usar Docker Hub Tokens
En lugar de tu contraseña:
1. Docker Hub → Account Settings → Security → New Access Token
2. Copia el token
3. Úsalo en lugar de la contraseña:
   ```bash
   docker login -u TU_USUARIO -p TOKEN
   ```

### 4. Multi-arquitectura (opcional)
Para soportar ARM64 (Apple Silicon, Raspberry Pi):
```bash
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 \
  -t TU_USUARIO/adso-app:latest --push .
```

---

## Verificar Imagen Subida

```bash
# Ver info de la imagen
docker manifest inspect TU_USUARIO/adso-app:latest

# Probar descarga
docker pull TU_USUARIO/adso-app:latest

# Ver en navegador
# https://hub.docker.com/r/TU_USUARIO/adso-app
```

---

## Troubleshooting

### Error: "denied: requested access to the resource is denied"
- Verifica que estés logueado: `docker login`
- Verifica el nombre de usuario

### Error: "manifest unknown"
- La imagen no existe en Docker Hub
- Verifica el nombre de la imagen

### Build muy lento
- Docker está descargando muchas dependencias
- Es normal la primera vez
- Builds subsecuentes serán más rápidos con caché

### Imagen muy pesada
- El Dockerfile ya usa multi-stage build
- Imagen final ~200-300MB (Spring Boot + JRE)
- Para optimizar más: usar JRE Alpine

---

## Costos

**Docker Hub Free Tier:**
- Repositorios públicos: Ilimitados
- Repositorios privados: 1 gratis
- Pulls: Ilimitados (con rate limiting)
- Almacenamiento: Ilimitado

**Comparado con Azure Container Registry:**
- ACR Basic: ~$5/mes
- Docker Hub puede ahorrar costos si usas tier gratuito

---

## Recursos

- [Docker Hub](https://hub.docker.com/)
- [Docker Hub Pricing](https://www.docker.com/pricing/)
- [Documentación Docker](https://docs.docker.com/)
- [GitHub Actions Docker](https://github.com/marketplace/actions/build-and-push-docker-images)

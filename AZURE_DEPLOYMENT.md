# Guía de Despliegue en Azure

Esta guía te ayudará a desplegar la aplicación ADSO en Azure usando diferentes servicios.

## Prerrequisitos

- Azure CLI instalado ([Descargar aquí](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli))
- Docker instalado localmente
- Una suscripción activa de Azure

## 💡 Alternativa: Usar Docker Hub (Más Económico)

**RECOMENDADO**: En lugar de Azure Container Registry (ACR), puedes usar Docker Hub (gratis):

1. Sube tu imagen a Docker Hub: `./docker-hub-push.sh TU_USUARIO`
2. Usa la imagen directamente: `TU_USUARIO/adso-app:latest`
3. Ahorra ~$5/mes del costo de ACR

Ver guía completa en [DOCKER_HUB.md](./DOCKER_HUB.md)

**Ejemplo con Docker Hub:**
```bash
# Despliegue directo desde Docker Hub
az container create \
  --resource-group adso-rg \
  --name adso-app \
  --image TU_USUARIO/adso-app:latest \
  --dns-name-label adso-app-unique \
  --ports 3005
```

---

## Opción 1: Azure Container Instances (ACI) - Más Simple

### Paso 1: Login en Azure
```bash
az login
```

### Paso 2: Crear un Resource Group
```bash
az group create --name adso-rg --location eastus
```

### Paso 3: Crear Azure Container Registry (ACR)
```bash
az acr create --resource-group adso-rg --name adsoacr --sku Basic
```

### Paso 4: Login en ACR
```bash
az acr login --name adsoacr
```

### Paso 5: Construir y subir la imagen
```bash
# Etiquetar la imagen
docker build -t adsoacr.azurecr.io/adso-app:latest .

# Subir a ACR
docker push adsoacr.azurecr.io/adso-app:latest
```

### Paso 6: Desplegar en Container Instances
```bash
# Habilitar admin en ACR
az acr update -n adsoacr --admin-enabled true

# Obtener credenciales
ACR_PASSWORD=$(az acr credential show --name adsoacr --query "passwords[0].value" -o tsv)

# Crear container instance
az container create \
  --resource-group adso-rg \
  --name adso-app \
  --image adsoacr.azurecr.io/adso-app:latest \
  --registry-login-server adsoacr.azurecr.io \
  --registry-username adsoacr \
  --registry-password $ACR_PASSWORD \
  --dns-name-label adso-app-unique \
  --ports 3005 \
  --cpu 1 \
  --memory 1
```

### Paso 7: Obtener la URL
```bash
az container show --resource-group adso-rg --name adso-app --query ipAddress.fqdn
```

Tu aplicación estará disponible en: `http://adso-app-unique.eastus.azurecontainer.io:3005`

---

## Opción 2: Azure App Service (Web App for Containers) - Recomendado

### Paso 1-5: Igual que la Opción 1

### Paso 6: Crear App Service Plan
```bash
az appservice plan create \
  --name adso-plan \
  --resource-group adso-rg \
  --is-linux \
  --sku B1
```

### Paso 7: Crear Web App
```bash
az webapp create \
  --resource-group adso-rg \
  --plan adso-plan \
  --name adso-webapp-unique \
  --deployment-container-image-name adsoacr.azurecr.io/adso-app:latest
```

### Paso 8: Configurar ACR en Web App
```bash
az webapp config container set \
  --name adso-webapp-unique \
  --resource-group adso-rg \
  --docker-custom-image-name adsoacr.azurecr.io/adso-app:latest \
  --docker-registry-server-url https://adsoacr.azurecr.io \
  --docker-registry-server-user adsoacr \
  --docker-registry-server-password $ACR_PASSWORD
```

### Paso 9: Configurar puerto de la aplicación
```bash
az webapp config appsettings set \
  --resource-group adso-rg \
  --name adso-webapp-unique \
  --settings WEBSITES_PORT=3005
```

Tu aplicación estará disponible en: `https://adso-webapp-unique.azurewebsites.net`

---

## Opción 3: Azure Kubernetes Service (AKS) - Para Producción

### Paso 1-5: Igual que las opciones anteriores

### Paso 6: Crear cluster AKS
```bash
az aks create \
  --resource-group adso-rg \
  --name adso-aks-cluster \
  --node-count 2 \
  --node-vm-size Standard_B2s \
  --attach-acr adsoacr \
  --generate-ssh-keys
```

### Paso 7: Conectar a AKS
```bash
az aks get-credentials --resource-group adso-rg --name adso-aks-cluster
```

### Paso 8: Crear archivo deployment.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: adso-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: adso-app
  template:
    metadata:
      labels:
        app: adso-app
    spec:
      containers:
      - name: adso-app
        image: adsoacr.azurecr.io/adso-app:latest
        ports:
        - containerPort: 3005
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: adso-app-service
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 3005
  selector:
    app: adso-app
```

### Paso 9: Desplegar
```bash
kubectl apply -f deployment.yaml
kubectl get service adso-app-service --watch
```

---

## Pruebas Locales

Antes de desplegar a Azure, prueba localmente:

```bash
# Construir imagen
docker build -t adso-app:latest .

# Ejecutar contenedor
docker run -p 3005:3005 adso-app:latest

# O usar docker-compose
docker-compose up
```

Accede a: `http://localhost:3005`

---

## Variables de Entorno (Opcional)

Si necesitas agregar variables de entorno:

**Para ACI:**
```bash
az container create \
  --environment-variables \
    'SPRING_PROFILES_ACTIVE'='prod' \
    'JWT_SECRET'='tu-secreto-aqui'
```

**Para App Service:**
```bash
az webapp config appsettings set \
  --settings \
    SPRING_PROFILES_ACTIVE=prod \
    JWT_SECRET=tu-secreto-aqui
```

---

## Monitoreo

### Logs en tiempo real

**ACI:**
```bash
az container logs --resource-group adso-rg --name adso-app --follow
```

**App Service:**
```bash
az webapp log tail --name adso-webapp-unique --resource-group adso-rg
```

**AKS:**
```bash
kubectl logs -f deployment/adso-app
```

---

## Actualizar la Aplicación

```bash
# 1. Construir nueva versión
docker build -t adsoacr.azurecr.io/adso-app:v2 .

# 2. Subir a ACR
docker push adsoacr.azurecr.io/adso-app:v2

# 3a. Actualizar ACI
az container create --resource-group adso-rg --name adso-app \
  --image adsoacr.azurecr.io/adso-app:v2 \
  [otros parámetros...]

# 3b. Actualizar App Service
az webapp config container set \
  --name adso-webapp-unique \
  --resource-group adso-rg \
  --docker-custom-image-name adsoacr.azurecr.io/adso-app:v2

# 3c. Actualizar AKS
kubectl set image deployment/adso-app adso-app=adsoacr.azurecr.io/adso-app:v2
```

---

## Limpieza de Recursos

Para eliminar todos los recursos:

```bash
az group delete --name adso-rg --yes --no-wait
```

---

## Costos Estimados (USD/mes)

- **ACI (1 vCPU, 1GB RAM)**: ~$30-40
- **App Service (B1)**: ~$13
- **AKS (2 nodos B2s)**: ~$70-80

---

## Soporte

Para más información:
- [Azure Container Instances](https://docs.microsoft.com/en-us/azure/container-instances/)
- [Azure App Service](https://docs.microsoft.com/en-us/azure/app-service/)
- [Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/aks/)

#!/bin/bash

# Script para construir y subir imagen a Docker Hub
# Uso: ./docker-hub-push.sh <tu-usuario-dockerhub> [version]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar argumentos
if [ -z "$1" ]; then
    echo -e "${RED}Error: Debes proporcionar tu usuario de Docker Hub${NC}"
    echo "Uso: ./docker-hub-push.sh <tu-usuario-dockerhub> [version]"
    echo "Ejemplo: ./docker-hub-push.sh juankos0714 1.0.0"
    exit 1
fi

DOCKER_USERNAME=$1
VERSION=${2:-latest}
IMAGE_NAME="adso-app"
FULL_IMAGE_NAME="${DOCKER_USERNAME}/${IMAGE_NAME}"

echo -e "${YELLOW}=====================================${NC}"
echo -e "${YELLOW}  Docker Hub Push Script${NC}"
echo -e "${YELLOW}=====================================${NC}"
echo ""
echo "Usuario Docker Hub: ${DOCKER_USERNAME}"
echo "Imagen: ${IMAGE_NAME}"
echo "Versión: ${VERSION}"
echo ""

# Verificar si Docker está instalado
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker no está instalado${NC}"
    exit 1
fi

# Login a Docker Hub
echo -e "${YELLOW}[1/4] Iniciando sesión en Docker Hub...${NC}"
docker login

# Construir imagen
echo -e "${YELLOW}[2/4] Construyendo imagen Docker...${NC}"
docker build -t ${FULL_IMAGE_NAME}:${VERSION} .

# Tagear como latest si no es latest
if [ "$VERSION" != "latest" ]; then
    echo -e "${YELLOW}[3/4] Taggeando imagen como latest...${NC}"
    docker tag ${FULL_IMAGE_NAME}:${VERSION} ${FULL_IMAGE_NAME}:latest
else
    echo -e "${YELLOW}[3/4] Imagen ya taggeada como latest${NC}"
fi

# Push a Docker Hub
echo -e "${YELLOW}[4/4] Subiendo imagen a Docker Hub...${NC}"
docker push ${FULL_IMAGE_NAME}:${VERSION}

if [ "$VERSION" != "latest" ]; then
    docker push ${FULL_IMAGE_NAME}:latest
fi

echo ""
echo -e "${GREEN}✓ ¡Éxito! Imagen subida a Docker Hub${NC}"
echo ""
echo -e "${GREEN}Tu imagen está disponible en:${NC}"
echo "  https://hub.docker.com/r/${DOCKER_USERNAME}/${IMAGE_NAME}"
echo ""
echo -e "${GREEN}Para usar esta imagen:${NC}"
echo "  docker pull ${FULL_IMAGE_NAME}:${VERSION}"
echo "  docker run -p 3005:3005 ${FULL_IMAGE_NAME}:${VERSION}"
echo ""
echo -e "${GREEN}En Azure App Service:${NC}"
echo "  az webapp create \\"
echo "    --resource-group adso-rg \\"
echo "    --plan adso-plan \\"
echo "    --name adso-app-unique \\"
echo "    --deployment-container-image-name ${FULL_IMAGE_NAME}:${VERSION}"
echo ""

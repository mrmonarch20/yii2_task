# Yii2 Application Deployment with Docker Swarm and GitHub Actions

## Overview

This project demonstrates how to containerize a Yii2 PHP application, deploy it using Docker Swarm on an AWS EC2 instance, and expose it via a host-based NGINX reverse proxy. CI/CD is set up using GitHub Actions.

---

## 1. Dockerizing the Yii2 PHP Application

- Uses `php:8.3-apache` as the base image.
- Installs required PHP extensions (`pdo`, `mbstring`, `gd`, etc.).
- Copies Yii2 source code into the container.
- Configures Apache to serve the app from `/web`.
- Docker image is built and tagged as `raja7977/yii2-app:latest .`

### Docker Build Command

```bash
docker build -t raja7977/yii2-app:latest .
```

---

## 2. Deploying with Docker Swarm

- Docker Swarm is initialized on the EC2 instance.
- The Yii2 app is deployed as a Swarm service:

```bash
docker service create \
  --name yii2_app_service \
  --replicas 1 \
  --publish 9000:80 \
  raja7977/yii2-app:latest
```

- To update the service with a new image:

```bash
docker service update \
  --image raja7977/yii2-app:latest \
  --force yii2_app_service
```

---

## 3. NGINX as a Host-Based Reverse Proxy

- NGINX is installed directly on the EC2 host.
- Configured to forward requests from port `80` to the Docker Swarm service on `9000`.

### Sample NGINX Config

```nginx
server {
    listen 80;
    server_name your-ec2-public-ip;

    location / {
        proxy_pass http://localhost:9000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

---

## 4. CI/CD with GitHub Actions

- A GitHub Actions workflow automates build and deployment on every push to the `main` branch.

### `.github/workflows/deploy.yml`

```yaml
name: Build and Deploy Yii2 to Docker Swarm

on:
  push:
    branches:
      - main

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Docker Hub login
        run: echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin

      - name: Build Docker image
        run: docker build -t ${{ secrets.DOCKER_USERNAME }}/yii2-app:latest .

      - name: Push image to Docker Hub
        run: docker push ${{ secrets.DOCKER_USERNAME }}/yii2-app:latest

      - name: Deploy to Docker Swarm via SSH
        uses: appleboy/ssh-action@v1.0.0
        with:
          host: ${{ secrets.EC2_HOST }}
          username: ${{ secrets.EC2_USER }}
          key: ${{ secrets.EC2_SSH_KEY }}
          script: |
            docker service update \
              --image ${{ secrets.DOCKERH_USERNAME }}/yii2-app:latest \
              --force yii2_app_service || \
            docker service create \
              --name yii2_app_service \
              --replicas 1 \
              --publish 9000:80 \
              ${{ secrets.DOCKERHUB_USERNAME }}/yii2-app:latest
```

---


# Yii2 Application Deployment with Docker Swarm & GitHub Actions

## Overview

Quickly deploy a Yii2 PHP app with Docker Swarm on AWS EC2, using NGINX as a reverse proxy and GitHub Actions for CI/CD.

---

## 1. Dockerizing Yii2

- Uses `php:8.3-apache`, installs needed extensions.
- App served from `/web`.
- Build image:
  ```bash
  docker build -t raja7977/yii2-app:latest .
  ```

---

## 2. Deploy on Docker Swarm

- Init Swarm on EC2, deploy service:
  ```bash
  docker service create --name yii2_app_service --replicas 1 --publish 9000:80 raja7977/yii2-app:latest
  ```
- Update with:
  ```bash
  docker service update --image raja7977/yii2-app:latest --force yii2_app_service
  ```

---

## 3. NGINX Reverse Proxy

- NGINX forwards port 80 to 9000.
- Example config:
  ```nginx
  server {
      listen 80;
      server_name your-ec2-public-ip;
      location / { proxy_pass http://localhost:9000; proxy_set_header Host $host; proxy_set_header X-Real-IP $remote_addr; }
  }
  ```

---

## 4. CI/CD (GitHub Actions)

- On push to `main`, workflow builds, pushes image to Docker Hub, deploys via SSH.

---

## Screenshots

### Yii2 Default Page
![Yii2 App Welcome](images/image1.png)
*Default Yii2 app landing page after deployment.*

### Docker Swarm Deployment
![Docker Swarm Terminal](images/image2.png)
*AWS EC2 terminal showing Docker image build, push, and Swarm service update.*

---


## Summary

✅ Dockerized Yii2 app  
✅ Deployed using Docker Swarm  
✅ Exposed via host-based NGINX reverse proxy  
✅ CI/CD via GitHub Actions with Docker Hub image push and remote deployment

This setup enables reliable, automated deployments for Yii2 applications using containerized DevOps best practices.

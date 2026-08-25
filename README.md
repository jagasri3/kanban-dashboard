# Kanban Dashboard

A Kanban-style task management application built with React, TypeScript and Vite.

## Technology Stack

- React
- TypeScript
- Vite
- Docker
- Nginx
- Jenkins
- GitHub
- Docker Hub
- AWS EC2

## Docker

The application is containerized using Docker and served through Nginx.

Docker images are tagged using the Git commit SHA, for example:

`jagasri2026/kanban-dashboard:f938bce`

The container uses:

- Memory limit: 512 MB
- CPU limit: 0.5 CPU

## CI/CD Pipeline

Jenkins automatically performs the following stages:

1. Checkout source code from GitHub
2. Generate Git commit SHA
3. Build the Docker image
4. Login to Docker Hub
5. Push the versioned Docker image
6. Deploy the image to AWS EC2
7. Perform application health checks
8. Mark the pipeline as successful or failed

## GitHub Webhook

A GitHub webhook is configured to trigger Jenkins automatically whenever code is pushed to the repository.

Flow:

GitHub Push → Webhook → Jenkins Pipeline → Docker Build → Docker Hub → EC2 Deployment

## Health Checks

The deployment validates:

- Docker container is running
- Docker HEALTHCHECK reports `healthy`
- Application endpoint responds successfully

## Deployment

The application is deployed on an AWS EC2 instance using Docker.

Application:

`http://65.2.75.198:8081`

## Monitoring

Docker logs, container status and health status can be checked using:

```bash
sudo docker ps
sudo docker logs kanban-dashboard
sudo docker inspect kanban-dashboard

# Docker Go builder

This image is based on the official _golang:alpine_ image, and adds some features on top of it to enable baking your own golang applications into docker images.

## Used versions:
- Go: 1.5.2
- Docker: 1.9.1

## Usage
1. Create an image with your Go application

```
docker run --rm \
  -v /host/your/project/source:/go/app \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gobuilder me/mygoapp
```

2. Run your application

```
docker run me/mygoapp
```
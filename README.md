# Docker Go builder

This image is based on the official _golang:alpine_ image, and adds some features on top of it to enable baking your own golang applications into docker images.

## Used versions:
- Go: 1.5.2
- Docker: 1.10.1

## Usage
### 1. Create an image with your Go application

In this example the name of the resulting image is me/mygoapp, and it will have included some files and directories from the initial app source: ```conf.yml```, ```static``` and ```views```. Including arbitrary directories or files from the source could be of a vital importance, if you are dockerizing a wep application, for example.

```
docker run --rm \
  -v /host/your/project/source:/go/app \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gobuilder \
  -n me/mygoapp \
  -d "conf.yml static views"
```

### 2. Run your application

```
docker run me/mygoapp
```

## Parameters of the builder

 - ```-n```: The resulting image name. Required.
 - ```-d```: A string with a space separated list of directories and/or files to be baked into the image. All paths must be relative to the project source directory.

## Details

This image is somewhat opinionated.

1. Your Go application that is being built is supposed to use 'vendor' approach, i.e. keep all the dependencies inside 'vendor' directory. It is considered an experimental feature in Go 1.5. See more details here: https://golang.org/s/go15vendor
2. Consequently, no ```go get``` will be performed when building the application.
3. The application is statically built into a single binary file.
4. This binary file is then baked into a docker image that is based on _scratch_ image. The resulting image is intended to be as small as possible.
 
Please, feel free to contribute to make this tool less opinionated and more configurable.
 
## See also

There is also an Ansible role to automate creation of a gobuilder image: https://github.com/meAmidos/ansible-build-go-builder

#!/bin/bash

# Ensure that there is a proper import path in the app package declaration
cd /go/app
pkgName="$(go list -e -f '{{.ImportComment}}' 2>/dev/null || true)"

if [ -z "$pkgName" ];
then
  echo "Error: Root package should have a canonical import path declared"
  exit 992
fi

# Construct Go package path
pkgPath="/go/src/$pkgName"

# Setup src directory tree in GOPATH
echo "Make dir $pkgPath"
mkdir -p "$(dirname "$pkgPath")"

# Copy app source into GOPATH
echo "Copy app source for building"
cp -R /go/app/ $pkgPath

# Compile statically linked version of the package
cd $pkgPath
echo "Building app $pkgName"
`CGO_ENABLED=${CGO_ENABLED:-0} go build -o /app/app.run -a --installsuffix cgo --ldflags="${LDFLAGS:--s}" $pkgName`

# Finally, dockerize the package
tagName=$1
echo "Building docker image $tagName"
docker build -t $tagName -f /app/Dockerfile /app

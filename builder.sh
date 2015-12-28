#!/bin/bash

# Ensure that there is a proper import path in the app package declaration
# Return package full name
function check_package {
	cd /go/app
	local pkg_name="$(go list -e -f {{.ImportComment}} 2>/dev/null || true)"

	if [ -z "$pkg_name" ];
	then
		echo "Error: Root package should have a canonical import path declared"
		exit 992
	fi

	echo $pkg_name
}

# Construct Go full package path and return it
function make_package_path {
	local pkg_name=$1
	local pkg_path="/go/src/$pkg_name"

	# Setup src directory tree in GOPATH
	mkdir -p "$(dirname "$pkg_path")"

	# Copy app source into GOPATH
	cp -R /go/app/ $pkg_path

	echo $pkg_path
}

function parse_arguments {
	local args=("$@")

	while [[ $# > 1 ]]
	do
	key="$1"

	case $key in
	    -n|--name)
		echo "Image name: $2"
	    IMAGE_NAME="$2"
	    shift
	    ;;
	    -d|--dirs)
		echo "Include dirs: $2"
	    INCLUDE_DIRS=$2
	    shift # past argument
	    ;;
	    *)
	        # unknown option
	    ;;
	esac
	shift # past argument or value
	done
}

function copy_app_dirs {
	local inc_dirs=$1
	local split_dirs=($inc_dirs)

	echo "Copy selected app files and directories:"
	
	# Root destination for files and directories that are being copied
	mkdir -p /app/build
	
	cd /go/app
	for i in "${split_dirs[@]}"
	do
		echo "...$i"
		if [ ! -f "$i" ]; then
			echo "Skip $i, does not exist"
			continue
		fi

		if [ -d "$i" ]; then
			mkdir -p /app/build/$i
			cd $i && cp -R . /app/build/$i
			cd ..
		else
			cp $i /app/build/$i
		fi
	done
}

# Compile statically linked version of package
function compile_app {
	pkg_name=$1
	pkg_path=$2

	echo "Building app $pkg_path"
	cd $pkg_path
	`CGO_ENABLED=${CGO_ENABLED:-0} go build -o /app/build/app.run -a --installsuffix cgo --ldflags="${LDFLAGS:--s}" $pkg_name`
}

function dockerize_app {
	local image_name=$1
	echo "Building docker image $IMAGE_NAME"
	docker build -t $image_name -f /app/Dockerfile /app
}

pkg_name=$(check_package)
echo "Check package: $pkg_name"

pkg_path=$(make_package_path $pkg_name)
echo "Package path: $pkg_path"

parse_arguments "$@"

copy_app_dirs "$INCLUDE_DIRS"
compile_app $pkg_name $pkg_path
dockerize_app $IMAGE_NAME

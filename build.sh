#!/bin/bash -x
script_file=`readlink -f "$0"`
script_dir=`dirname "$script_file"`
lsb_rel='latest'
got_lsb_rel=0

image_name='samba-dc'
docker_user='rothan'

function usage() {
	echo "Usage: $script_file [OPTIONS] [DEBPKGDIR] [CONTAINER]"
	echo "OPTIONS:"
	echo "    -h, --help            shows this help"
	echo "    -v, --verbose         enable verbose output"
	echo ""
	echo "  LSB_RELEASE    name of the ubuntu release (default $lsb_rel)"
	exit 0
}

# parse command line arguments
while [ $# -ne 0 ]; do
	case "$1" in
	'-?'|'-h'|'--help') usage;;
	'-v'|'--verbose') verbose=1; ;;
	-*)
		echo "Unrecognized option $1" >&2
		exit 1
		;;
	*)
        if [ $got_lsb_rel -eq 0 ]; then
            lsb_rel="$1"
            got_lsb_rel=1
        else
			echo "LSB release $lsb_rel already specified." >&2
			exit 1
		fi
		;;
	esac
	shift
done


docker build --tag ${image_name}:$lsb_rel "$script_dir"
docker tag ${image_name}:$lsb_rel $docker_user/${image_name}:$lsb_rel

docker login --username "${docker_user}"
docker push $docker_user/${image_name}:$lsb_rel

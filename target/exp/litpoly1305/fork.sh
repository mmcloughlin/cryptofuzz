#!/bin/bash -e

source ../../../script/lib.sh

clref='refs/changes/37/169037/3' 
pkg="golang.org/x/crypto"
this_pkg=$(target_import_path poly1305)
dst="fork"

# Make a temp GOPATH.
export GOPATH=$(mktemp -d)

# Clone the repo at the given CL.
pkgpath="${GOPATH}/src/${pkg}"
git clone "https://go.googlesource.com/crypto" ${pkgpath}
cd ${pkgpath}
git pull "https://go.googlesource.com/crypto" ${clref}
cd -

# Clean existing forked packages.
rm -rf ${dst}

# Fork noasm version.
heading 'fork noasm version (mips architecture)'
fork_package_for_arch ${pkg}/poly1305 mips ${dst}

# Confirm build.
heading "go build"
go build -v ./${dst}
 
heading "go test"
go test -v -cover ./${dst}
 
# Report.
heading "forked package"
tree ${dst}

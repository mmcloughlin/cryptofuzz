#!/bin/bash -e

source ../../script/lib.sh

pkg="crypto/sha1"
this_pkg=$(target_import_path sha1)
dst="fork"

# Clean existing forked packages.
rm -rf ${dst}

# Fork two versions.
heading 'fork asm version'
fork_package_for_arch ${pkg} amd64 ${dst}/asm

heading 'fork noasm version (mips architecture)'
fork_package_for_arch ${pkg} mips ${dst}/noasm

# Clone supporting packages.
heading "clone internal/cpu"
clone_package {,${dst}/}internal/cpu
rewrite_imports ${dst} {,${this_pkg}/${dst}/}internal/cpu

# Confirm they build.
heading "go build"
go build -v ./${dst}/...

heading "go test"
go test -v -cover ./${dst}/*asm

# Report.
heading "forked packages"
tree ${dst}

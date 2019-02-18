#!/bin/bash -e

source ../../script/lib.sh

pkg="golang.org/x/crypto/poly1305"
this_pkg=$(target_import_path poly1305)
dst="fork"

# Clean existing forked packages.
rm -rf ${dst}

# Fork two versions.
heading 'fork asm version'
fork_package_for_arch ${pkg} amd64 ${dst}/asm

heading 'fork noasm version (mips architecture)'
fork_package_for_arch ${pkg} mips ${dst}/noasm

# Confirm they build.
heading "go build"
go build -v ./${dst}/...

heading "go test"
go test -v -cover ./${dst}/*asm

# Report.
heading "forked packages"
tree ${dst}

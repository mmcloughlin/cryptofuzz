#!/bin/bash -e

source ../../script/lib.sh

pkg="golang.org/x/crypto/chacha20poly1305"
this_pkg=$(target_import_path chacha20poly1305)
dst="fork"

# Clean existing forked packages.
rm -rf ${dst}

# Fork two versions.
heading 'fork asm version'
fork_package_for_arch ${pkg} amd64 ${dst}/asm

heading 'fork noasm version (mips architecture)'
fork_package_for_arch ${pkg} mips ${dst}/noasm

# Clone supporting packages.
for name in subtle chacha20; do
    src_pkg=golang.org/x/crypto/internal/${name}
    local_path=${dst}/internal/${name}

    heading "clone ${src_pkg}"
    clone_package ${src_pkg} ${local_path}
done

heading "rewrite imports"
for name in subtle chacha20; do
    rewrite_imports ${dst} {golang.org/x/crypto,${this_pkg}/${dst}}/internal/${name}
done

# Confirm they build.
heading "go build"
go build -v ./${dst}/...

heading "go test"
go test -v -cover ./${dst}/...

# Report.
heading "forked packages"
tree ${dst}

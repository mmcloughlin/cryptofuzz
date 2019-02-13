#!/bin/bash -e

source ../../script/lib.sh

pkg="golang.org/x/crypto/blake2b"
this_pkg=$(target_import_path blake2b)
dst="fork"

# Clean existing forked package.
rm -rf ${dst}

# Fork two versions.
heading 'fork amd64 version'
fork_package_for_arch ${pkg} amd64 ${dst}

# Write custom functions to control which implementation is used.
cat > ${dst}/switch_amd64.go <<EOF
package blake2b

import "golang.org/x/sys/cpu"

// UseAVX2 forces the AVX2 implementation to be used, if available.
func UseAVX2()    { useSSE4, useAVX, useAVX2 = false, false, cpu.X86.HasAVX2 }

// UseAVX forces the AVX implementation to be used, if available.
func UseAVX()     { useSSE4, useAVX, useAVX2 = false, cpu.X86.HasAVX, false }

// UseSSE4 forces the SSE4 implementation to be used, if available.
func UseSSE4()    { useSSE4, useAVX, useAVX2 = cpu.X86.HasSSE41, false, false }

// UseGeneric forces the pure Go implementation to be used.
func UseGeneric() { useSSE4, useAVX, useAVX2 = false, false, false }
EOF

# Confirm it builds.
heading "go build"
go build -v ./${dst}/...

heading "go test"
go test -v -cover ./${dst}

# Report.
heading "forked package"
tree ${dst}

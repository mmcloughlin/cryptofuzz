#!/bin/bash -e

source ../../script/lib.sh

pkg="golang.org/x/crypto/blake2s"
this_pkg=$(target_import_path blake2s)
dst="fork"

# Clean existing forked package.
rm -rf ${dst}

# Fork two versions.
heading 'fork amd64 version'
fork_package_for_arch ${pkg} amd64 ${dst}

# Write custom functions to control which implementation is used.
cat > ${dst}/switch_amd64.go <<EOF
package blake2s

import "golang.org/x/sys/cpu"

// UseSSE4 forces the SSE4 implementation to be used, if available.
func UseSSE4()    { useSSE2, useSSSE3, useSSE4 = false, false, cpu.X86.HasSSE41 }

// UseSSSE3 forces the SSSE3 implementation to be used, if available.
func UseSSSE3()    { useSSE2, useSSSE3, useSSE4 = false, cpu.X86.HasSSSE3, false }

// UseSSE2 forces the SSE2 implementation to be used, if available.
func UseSSE2()    { useSSE2, useSSSE3, useSSE4 = cpu.X86.HasSSE2, false, false }

// UseGeneric forces the pure Go implementation to be used.
func UseGeneric() { useSSE2, useSSSE3, useSSE4 = false, false, false }
EOF

# Confirm it builds.
heading "go build"
go build -v ./${dst}/...

heading "go test"
go test -v -cover ./${dst}

# Report.
heading "forked package"
tree ${dst}

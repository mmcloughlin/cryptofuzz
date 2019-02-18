package poly1305

import (
	"bytes"

	asm "github.com/mmcloughlin/cryptofuzz/target/poly1305/fork/asm"
	noasm "github.com/mmcloughlin/cryptofuzz/target/poly1305/fork/noasm"
)

func Fuzz(data []byte) int {
	if len(data) < 32 {
		return -1
	}
	var key [32]byte
	copy(key[:], data)
	data = data[32:]

	var a, b [16]byte
	asm.Sum(&a, data, &key)
	noasm.Sum(&b, data, &key)

	if !bytes.Equal(a[:], b[:]) {
		panic("mismatch")
	}

	return 1
}

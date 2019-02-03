package curve25519

import (
	"bytes"

	asm "github.com/mmcloughlin/cryptofuzz/target/curve25519/fork/asm"
	noasm "github.com/mmcloughlin/cryptofuzz/target/curve25519/fork/noasm"
)

func Fuzz(data []byte) int {
	if len(data) < 64 {
		return -1
	}

	var in, base [32]byte
	copy(in[:], data[:32])
	copy(base[:], data[32:64])

	var a, b [32]byte
	asm.ScalarMult(&a, &in, &base)
	noasm.ScalarMult(&b, &in, &base)

	if !bytes.Equal(a[:], b[:]) {
		panic("mismatch")
	}

	return 1
}

package curve25519

import (
	"bytes"
	"fmt"

	asm "github.com/mmcloughlin/cryptofuzz/target/curve25519/fork/asm"
	noasm "github.com/mmcloughlin/cryptofuzz/target/curve25519/fork/noasm"
)

func Fuzz(data []byte) int {
	if len(data) < 64 {
		return -1
	}

	var a, b [32]byte
	var in, base [32]byte

	copy(in[:], data[:32])
	copy(base[:], data[32:64])
	asm.ScalarMult(&a, &in, &base)

	copy(in[:], data[:32])
	copy(base[:], data[32:64])
	noasm.ScalarMult(&b, &in, &base)

	if !bytes.Equal(a[:], b[:]) {
		fmt.Printf("  in = %x\n", in)
		fmt.Printf("base = %x\n", base)
		fmt.Printf("   a = %x\n", a)
		fmt.Printf("   b = %x\n", b)
		panic("mismatch")
	}

	return 1
}

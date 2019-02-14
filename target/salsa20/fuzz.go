package salsa20

import (
	"bytes"
	"fmt"

	asm "github.com/mmcloughlin/cryptofuzz/target/salsa20/fork/asm"
	noasm "github.com/mmcloughlin/cryptofuzz/target/salsa20/fork/noasm"
)

func Fuzz(data []byte) int {
	// Read key.
	if len(data) < 32 {
		return -1
	}
	key := data[:32]
	data = data[32:]

	// Read counter.
	if len(data) < 16 {
		return -1
	}
	counter := data[:16]
	data = data[16:]

	// Compute assembly and generic versions.
	n := len(data)
	var c [16]byte
	var k [32]byte

	out := make([]byte, n)
	copy(c[:], counter)
	copy(k[:], key)
	asm.XORKeyStream(out, data, &c, &k)

	ref := make([]byte, n)
	copy(c[:], counter)
	copy(k[:], key)
	noasm.XORKeyStream(ref, data, &c, &k)

	if !bytes.Equal(out, ref) {
		fmt.Printf("counter=%x\n", counter)
		fmt.Printf("key=%x\n", key)
		fmt.Printf("data=%x\n", data)
		fmt.Printf("out=%x\n", out)
		fmt.Printf("ref=%x\n", ref)
		panic("mismatch")
	}

	return 0
}

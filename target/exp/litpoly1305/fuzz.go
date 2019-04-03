package litpoly1305

import (
	"bytes"

	target "github.com/mmcloughlin/cryptofuzz/target/exp/litpoly1305/fork"
	"golang.org/x/crypto/poly1305"
)

func Fuzz(data []byte) int {
	if len(data) < 32 {
		return -1
	}
	var key [32]byte
	copy(key[:], data)
	data = data[32:]

	var a, b [16]byte
	poly1305.Sum(&a, data, &key)
	target.Sum(&b, data, &key)

	if !bytes.Equal(a[:], b[:]) {
		panic("mismatch")
	}

	return 1
}

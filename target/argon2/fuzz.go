package argon2

import (
	"bytes"

	"github.com/mmcloughlin/cryptofuzz/fuzz"
	asm "github.com/mmcloughlin/cryptofuzz/target/argon2/fork/asm"
	noasm "github.com/mmcloughlin/cryptofuzz/target/argon2/fork/noasm"
)

const (
	time    = 1
	memory  = 32 * 1024
	threads = 4
)

func Fuzz(data []byte) int {
	r, data, err := fuzz.Rand(data)
	if err != nil {
		return -1
	}

	// Pick the password and salt.
	n := len(data)
	if n < 2 {
		return -1
	}
	s := 1 + r.Intn(n-1)
	password := data[:s]
	salt := data[s:]

	// Key length.
	bits := uint(r.Intn(10))
	keylen := uint32(1) << bits

	// Compute both.
	a := asm.Key(password, salt, time, memory, threads, keylen)
	b := noasm.Key(password, salt, time, memory, threads, keylen)

	if !bytes.Equal(a, b) {
		panic("mismatch")
	}

	return 1
}

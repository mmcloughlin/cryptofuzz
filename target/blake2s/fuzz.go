package blake2s

import (
	"bytes"
	"math/rand"

	"github.com/mmcloughlin/cryptofuzz/fuzz"
	blake2s "github.com/mmcloughlin/cryptofuzz/target/blake2s/fork"
)

func Fuzz(data []byte) int {
	r, data, err := fuzz.Rand(data)
	if err != nil {
		return -1
	}

	// Read key.
	n := 1 + r.Intn(32)
	if len(data) < n {
		return -1
	}
	key := data[:n]
	data = data[n:]

	// Reference.
	blake2s.UseGeneric()
	ref := sum(r, key, data)

	// Optimized versions.
	versions := map[string]func(){
		"sse2":  blake2s.UseSSE2,
		"ssse3": blake2s.UseSSSE3,
		"sse4":  blake2s.UseSSE4,
	}
	for name, enable := range versions {
		enable()
		s := sum(r, key, data)
		if !bytes.Equal(ref, s) {
			panic("mismatch " + name)
		}
	}

	return 1
}

func sum(r *rand.Rand, key, b []byte) []byte {
	h, err := blake2s.New256(key)
	if err != nil {
		panic(err.Error())
	}
	fuzz.RandWrite(h, r, b)
	return h.Sum(nil)
}

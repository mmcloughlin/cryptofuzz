package blake2b

import (
	"bytes"
	"math/rand"

	"github.com/mmcloughlin/cryptofuzz/fuzz"
	blake2b "github.com/mmcloughlin/cryptofuzz/target/blake2b/fork"
)

func Fuzz(data []byte) int {
	r, data, err := fuzz.Rand(data)
	if err != nil {
		return -1
	}

	// Read key.
	n := 1 + r.Intn(64)
	if len(data) < n {
		return -1
	}
	key := data[:n]
	data = data[n:]

	// Reference.
	blake2b.UseGeneric()
	ref := sum(r, key, data)

	// Optimized versions.
	versions := map[string]func(){
		"avx2": blake2b.UseAVX2,
		"avx":  blake2b.UseAVX,
		"sse4": blake2b.UseSSE4,
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
	h, err := blake2b.New512(key)
	if err != nil {
		panic(err.Error())
	}
	fuzz.RandWrite(h, r, b)
	return h.Sum(nil)
}

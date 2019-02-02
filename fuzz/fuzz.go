// Package fuzz provides generic fuzzers for crypto interfaces.
package fuzz

import (
	"bytes"
	"encoding/binary"
	"hash"
	"io"
	"math/rand"
)

// Hash compares two hash implementations on the given fuzz data.
func Hash(data []byte, a, b hash.Hash) int {
	// Seed an RNG.
	if len(data) < 4 {
		return -1
	}
	seed := binary.BigEndian.Uint32(data)
	data = data[4:]
	r := rand.New(rand.NewSource(int64(seed)))

	// Write to hash in random chunks.
	h := io.MultiWriter(a, b)
	for len(data) > 0 {
		m := 1 + r.Intn(len(data))
		chunk := data[:m]
		data = data[m:]

		n, err := h.Write(chunk)
		if err != nil {
			panic(err.Error())
		}
		if n != len(chunk) {
			panic("short write")
		}
	}

	// Compare checksums.
	asum := a.Sum(nil)
	bsum := b.Sum(nil)

	if !bytes.Equal(asum, bsum) {
		panic("mismatch")
	}

	return 0
}

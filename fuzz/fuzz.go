// Package fuzz provides generic fuzzers for crypto interfaces.
package fuzz

import (
	"bytes"
	"hash"
	"io"
)

// Hash compares two hash implementations on the given fuzz data.
func Hash(data []byte, a, b hash.Hash) int {
	h := io.MultiWriter(a, b)
	n, err := h.Write(data)
	if err != nil {
		panic(err.Error())
	}
	if n != len(data) {
		panic("short write")
	}

	// Compare checksums.
	asum := a.Sum(nil)
	bsum := b.Sum(nil)

	if !bytes.Equal(asum, bsum) {
		panic("mismatch")
	}

	return 0
}

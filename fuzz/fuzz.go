// Package fuzz provides generic fuzzers for crypto interfaces.
package fuzz

import (
	"bytes"
	"crypto/elliptic"
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

// Curve compares c to its generic implementation on the given fuzz data.
func Curve(data []byte, c elliptic.Curve) int {
	ref := c.Params()
	n := ref.BitSize / 8

	// ScalarBaseMult
	if len(data) < n {
		return -1
	}
	s := data[:n]
	data = data[n:]

	x, y := c.ScalarBaseMult(s)
	rx, ry := ref.ScalarBaseMult(s)

	if x.Cmp(rx) != 0 || y.Cmp(ry) != 0 {
		panic("mismatch ScalarBaseMult")
	}

	// ScalarMult
	if len(data) < n {
		return -1
	}
	s = data[:n]
	data = data[n:]

	x, y = c.ScalarMult(x, y, s)
	rx, ry = ref.ScalarMult(rx, ry, s)

	if x.Cmp(rx) != 0 || y.Cmp(ry) != 0 {
		panic("mismatch ScalarMult")
	}

	// Confirm Add and Double have expected properties.
	ax, ay := c.Add(x, y, x, y)
	dx, dy := c.Double(x, y)
	if ax.Cmp(dx) != 0 || ay.Cmp(dy) != 0 {
		panic("mismatch between Add and Double")
	}

	return 0
}
